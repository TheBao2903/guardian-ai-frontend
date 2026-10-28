import 'dart:async';
import 'package:dio/dio.dart';
import 'audio_analysis_transport.dart';
import 'audio_monitoring_status.dart';
import 'server_audio_alert.dart';

/// Holds one candidate in memory. Overlapping detections coalesce into it.
/// Retries keep the exact payload/idempotency key; stale events never replay.
class AudioAlertDispatcher {
  AudioAlertDispatcher(
      {required this.transport,
      required this.onAccepted,
      required this.onStatus,
      DateTime Function()? now,
      this.maxAge = const Duration(seconds: 25),
      this.retryBase = const Duration(seconds: 1),
      this.maxAttempts = 3,
      this.attemptBudget = const Duration(seconds: 4)})
      : now = now ?? DateTime.now;

  final AudioAnalysisTransport transport;
  final Future<void> Function(ServerAudioAlert) onAccepted;
  final void Function(AudioAlertDelivery, AudioFailureKind, String) onStatus;
  final DateTime Function() now;
  final Duration maxAge, retryBase, attemptBudget;
  final int maxAttempts;
  bool _busy = false, _disposed = false;
  int _epoch = 0;
  CancelToken? _token;
  Timer? _delay;
  Completer<void>? _waiting;
  bool get isBusy => _busy;

  void submit(Map<String, dynamic> candidate, DateTime capturedAt) {
    if (_busy || _disposed) return;
    _busy = true;
    unawaited(_send(
        Map<String, dynamic>.unmodifiable(candidate), capturedAt, _epoch));
  }

  Future<void> _send(
      Map<String, dynamic> candidate, DateTime capturedAt, int epoch) async {
    bool valid() => !_disposed && epoch == _epoch;
    try {
      for (var attempt = 0; attempt < maxAttempts && valid(); attempt++) {
        final remaining = maxAge - now().difference(capturedAt);
        if (remaining <= Duration.zero) {
          onStatus(AudioAlertDelivery.expired, AudioFailureKind.stale,
              'STALE_AUDIO');
          return;
        }
        onStatus(
            attempt == 0
                ? AudioAlertDelivery.sending
                : AudioAlertDelivery.retrying,
            AudioFailureKind.none,
            '');
        _token = CancelToken();
        ServerAudioAlert alert;
        try {
          final data = await transport.post('/detection/alerts', candidate,
              cancelToken: _token!,
              budget: remaining < attemptBudget ? remaining : attemptBudget);
          if (!valid()) return;
          alert = ServerAudioAlert.fromJson(data as Map);
        } catch (error) {
          if (!valid()) return;
          final failure = error is AudioRequestFailure
              ? error
              : const AudioRequestFailure(
                  AudioFailureKind.server, 'INVALID_ALERT_RESPONSE');
          final retry = failure.retryable && attempt + 1 < maxAttempts;
          onStatus(
              retry ? AudioAlertDelivery.retrying : AudioAlertDelivery.failed,
              failure.kind,
              failure.code);
          if (!retry) return;
          final waiting = _waiting = Completer<void>();
          _delay = Timer(retryBase * (1 << attempt), () {
            if (!waiting.isCompleted) waiting.complete();
          });
          await waiting.future;
          if (epoch == _epoch) _waiting = null;
          continue;
        }
        // Acceptance must never be retried because a subsequent UI sync failed.
        onStatus(AudioAlertDelivery.accepted, AudioFailureKind.none, '');
        try {
          await onAccepted(alert);
        } catch (_) {/* Realtime reconciles. */}
        return;
      }
    } finally {
      if (epoch == _epoch) _busy = false;
    }
  }

  void cancel() {
    _epoch++;
    _token?.cancel('MONITORING_STOPPED');
    _delay?.cancel();
    if (_waiting?.isCompleted == false) _waiting!.complete();
    _waiting = null;
    _busy = false;
  }

  void dispose() {
    _disposed = true;
    cancel();
  }
}
