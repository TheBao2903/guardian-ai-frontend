import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_alert_dispatcher.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_analysis_queue.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_analysis_transport.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_monitoring_status.dart';

class ControlledTransport implements AudioAnalysisTransport {
  final calls = <Map<String, dynamic>>[];
  final tokens = <CancelToken>[];
  final replies = <Completer<dynamic>>[];
  @override
  Future<dynamic> post(String path, Map<String, dynamic> data,
      {required CancelToken cancelToken, required Duration budget}) {
    calls.add(data);
    tokens.add(cancelToken);
    final reply = Completer<dynamic>();
    replies.add(reply);
    return reply.future;
  }
}

Map<String, dynamic> acceptedAlert() => {
      'alert_id': 'a' * 40,
      'status': 'PENDING',
      'deadline_at':
          DateTime.utc(2026).add(const Duration(seconds: 10)).toIso8601String(),
      'server_time': DateTime.utc(2026).toIso8601String(),
    };

void main() {
  final now = DateTime.utc(2026);
  final chunk = Uint8List(38400)..[0] = 1;
  test('queue bounds memory and skips expired windows in favour of fresh audio',
      () {
    final queue = AudioAnalysisQueue();
    for (var second = 0; second < 10; second++) {
      queue.add(chunk, capturedAt: now.add(Duration(seconds: second)));
    }
    expect(queue.pendingCount, 4);
    expect(queue.droppedWindows, greaterThan(0));
    final next = queue.takeNext(now: now.add(const Duration(seconds: 12)));
    expect(next, isNotNull);
    expect(now.add(const Duration(seconds: 12)).difference(next!.capturedAt),
        lessThanOrEqualTo(const Duration(seconds: 4)));
    expect(queue.expiredWindows, greaterThan(0));
    expect(queue.takeNext(now: now.add(const Duration(minutes: 1))), isNull);
  });

  test('historical losses do not keep warning after two fresh successes', () {
    final health = AudioHealthTracker();
    expect(health.success(totalLosses: 7, age: Duration.zero),
        AudioAnalysisHealth.delayed);
    expect(health.success(totalLosses: 7, age: Duration.zero),
        AudioAnalysisHealth.delayed);
    expect(health.success(totalLosses: 7, age: Duration.zero),
        AudioAnalysisHealth.healthy);
    health.failed();
    expect(health.success(totalLosses: 7, age: Duration.zero),
        AudioAnalysisHealth.unavailable);
    expect(health.success(totalLosses: 7, age: Duration.zero),
        AudioAnalysisHealth.healthy);
  });

  testWidgets(
      'lost response retries same candidate, coalesces overlapping detections',
      (tester) async {
    final transport = ControlledTransport();
    final statuses = <AudioAlertDelivery>[];
    var accepted = 0;
    final sender = AudioAlertDispatcher(
        transport: transport,
        now: () => now,
        onAccepted: (_) async => accepted++,
        onStatus: (status, _, __) => statuses.add(status));
    sender.submit({'idempotency_key': 'stream:1', 'confidence': .8}, now);
    sender.submit({'idempotency_key': 'stream:2'}, now);
    expect(transport.calls.length, 1);
    transport.replies.first.completeError(const AudioRequestFailure(
        AudioFailureKind.network, 'RESPONSE_LOST',
        retryable: true));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(transport.calls.length, 2);
    expect(transport.calls[1], transport.calls[0]);
    transport.replies.last.complete(acceptedAlert());
    await tester.pump();
    expect(accepted, 1);
    expect(statuses.last, AudioAlertDelivery.accepted);
    expect(sender.isBusy, false);
    sender.dispose();
  });

  testWidgets(
      'retry is bounded and permanent authentication errors never retry',
      (tester) async {
    for (final retryable in [false, true]) {
      final transport = ControlledTransport();
      final statuses = <AudioAlertDelivery>[];
      final sender = AudioAlertDispatcher(
          transport: transport,
          now: () => now,
          onAccepted: (_) async {},
          onStatus: (status, _, __) => statuses.add(status));
      sender.submit({'idempotency_key': 'stream:1'}, now);
      final attempts = retryable ? 3 : 1;
      for (var attempt = 0; attempt < attempts; attempt++) {
        transport.replies.last.completeError(AudioRequestFailure(
            retryable
                ? AudioFailureKind.network
                : AudioFailureKind.authentication,
            'TEST',
            retryable: retryable));
        await tester.pump();
        await tester.pump(Duration(seconds: 1 << attempt));
      }
      expect(transport.calls.length, attempts);
      expect(statuses.last, AudioAlertDelivery.failed);
      sender.dispose();
    }
  });

  testWidgets('events expire during backoff and cannot replay after reconnect',
      (tester) async {
    var clock = now;
    final transport = ControlledTransport();
    final statuses = <AudioAlertDelivery>[];
    final sender = AudioAlertDispatcher(
        transport: transport,
        now: () => clock,
        onAccepted: (_) async {},
        onStatus: (status, _, __) => statuses.add(status));
    sender.submit({'idempotency_key': 'stream:1'}, now);
    transport.replies.single.completeError(const AudioRequestFailure(
        AudioFailureKind.network, 'OFFLINE',
        retryable: true));
    await tester.pump();
    clock = now.add(const Duration(seconds: 26));
    await tester.pump(const Duration(seconds: 1));
    expect(transport.calls.length, 1);
    expect(statuses.last, AudioAlertDelivery.expired);
    sender.dispose();
  });

  testWidgets('stopping cancels upload and ignores a late accepted response',
      (tester) async {
    final transport = ControlledTransport();
    var accepted = 0;
    final sender = AudioAlertDispatcher(
        transport: transport,
        now: () => now,
        onAccepted: (_) async => accepted++,
        onStatus: (_, __, ___) {});
    sender.submit({'idempotency_key': 'old:1'}, now);
    sender.cancel();
    expect(transport.tokens.first.isCancelled, true);
    transport.replies.first.complete(acceptedAlert());
    await tester.pump();
    expect(accepted, 0);
    sender.dispose();
  });

  testWidgets('accepted alert is not retried when subsequent UI sync fails',
      (tester) async {
    final transport = ControlledTransport();
    final sender = AudioAlertDispatcher(
        transport: transport,
        now: () => now,
        onAccepted: (_) async => throw StateError('UI unavailable'),
        onStatus: (_, __, ___) {});
    sender.submit({'idempotency_key': 'stream:1'}, now);
    transport.replies.single.complete(acceptedAlert());
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(transport.calls.length, 1);
    sender.dispose();
  });
}
