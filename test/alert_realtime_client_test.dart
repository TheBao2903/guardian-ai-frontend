import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/device/audio/detection/alert_realtime_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FakeSink implements WebSocketSink {
  final messages = <dynamic>[];
  bool closed = false;

  @override
  void add(dynamic data) => messages.add(jsonDecode(data as String));

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    closed = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeChannel implements WebSocketChannel {
  final incoming = StreamController<dynamic>();
  @override
  final FakeSink sink = FakeSink();
  @override
  Stream<dynamic> get stream => incoming.stream;
  @override
  Future<void> get ready => Future.value();

  void state([Map<String, dynamic>? data]) =>
      incoming.add(jsonEncode({'type': 'AUDIO_ALERT', 'data': data}));

  Future<void> close() {
    unawaited(sink.close());
    return incoming.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
      'websocket URL follows API host, scheme and prefix without query secrets',
      () {
    expect(
        AlertRealtimeClient.streamUrl(
                'https://example.com/api/v1/?token=secret')
            .toString(),
        'wss://example.com/api/v1/detection/alerts/stream');
    expect(
        AlertRealtimeClient.streamUrl('http://localhost:8000/api/v1')
            .toString(),
        'ws://localhost:8000/api/v1/detection/alerts/stream');
  });

  testWidgets('healthy realtime stops per-second HTTP polling', (tester) async {
    final channel = FakeChannel();
    var polls = 0;
    final received = <Map<dynamic, dynamic>?>[];
    final client = AlertRealtimeClient(
      url: Uri.parse('ws://localhost/alerts'),
      readToken: () async => 'token',
      synchronize: () async => polls++,
      onAlert: (alert) async => received.add(alert),
      connect: (_) => channel,
    );
    client.start();
    await tester.pump();
    expect(channel.sink.messages.single, {'type': 'AUTH', 'token': 'token'});
    channel.state();
    await tester.pump();
    final initialPolls = polls;
    await tester.pump(const Duration(seconds: 10));
    expect(polls, initialPolls);
    channel.state({'alert_id': 'a', 'status': 'PENDING'});
    await tester.pump();
    expect(received.last?['status'], 'PENDING');
    client.stop();
    unawaited(channel.incoming.close());
    await tester.pump();
  });

  testWidgets('disconnect enables polling and reconnect loads state again',
      (tester) async {
    final channels = <FakeChannel>[];
    var polls = 0;
    final client = AlertRealtimeClient(
      url: Uri.parse('ws://localhost/alerts'),
      readToken: () async => 'token',
      synchronize: () async => polls++,
      onAlert: (_) async {},
      connect: (_) {
        final channel = FakeChannel();
        channels.add(channel);
        return channel;
      },
    );
    client.start();
    await tester.pump();
    channels.first.state();
    await tester.pump();
    final before = polls;
    unawaited(channels.first.incoming.close());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(polls, greaterThan(before));
    expect(channels.length, 2);
    channels.last.state({'status': 'CANCELLED'});
    await tester.pump();
    final reconnectedPolls = polls;
    await tester.pump(const Duration(seconds: 5));
    expect(polls, reconnectedPolls);
    client.stop();
    unawaited(channels.last.incoming.close());
    await tester.pump();
  });

  testWidgets('silent socket falls back without waiting for onDone',
      (tester) async {
    var now = DateTime.utc(2026);
    final channel = FakeChannel();
    var polls = 0;
    final client = AlertRealtimeClient(
      url: Uri.parse('ws://localhost/alerts'),
      now: () => now,
      readToken: () async => 'token',
      synchronize: () async => polls++,
      onAlert: (_) async {},
      connect: (_) => channel,
    );
    client.start();
    await tester.pump();
    channel.state();
    await tester.pump();
    final before = polls;
    now = now.add(const Duration(seconds: 36));
    await tester.pump(const Duration(seconds: 1));
    expect(channel.sink.closed, isTrue);
    expect(polls, greaterThan(before));
    client.stop();
    unawaited(channel.incoming.close());
    await tester.pump();
  });

  testWidgets('heartbeat cannot hide a stalled state feed', (tester) async {
    var now = DateTime.utc(2026);
    final channel = FakeChannel();
    final client = AlertRealtimeClient(
      url: Uri.parse('ws://localhost/alerts'),
      now: () => now,
      readToken: () async => 'token',
      synchronize: () async {},
      onAlert: (_) async {},
      connect: (_) => channel,
    );
    client.start();
    await tester.pump();
    channel.state();
    await tester.pump();
    now = now.add(const Duration(seconds: 91));
    channel.incoming.add(jsonEncode({'type': 'HEARTBEAT'}));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(channel.sink.closed, isTrue);
    client.stop();
    unawaited(channel.incoming.close());
    await tester.pump();
  });

  testWidgets('reads refreshed token after HTTP synchronization',
      (tester) async {
    var token = 'expired';
    final channel = FakeChannel();
    final client = AlertRealtimeClient(
      url: Uri.parse('ws://localhost/alerts'),
      readToken: () async => token,
      synchronize: () async {
        token = 'refreshed';
      },
      onAlert: (_) async {},
      connect: (_) => channel,
    );
    client.start();
    await tester.pump();
    expect(channel.sink.messages.single['token'], 'refreshed');
    client.stop();
    unawaited(channel.incoming.close());
    await tester.pump();
  });

  testWidgets('resume reconnects and logout ignores old queued updates',
      (tester) async {
    final channels = <FakeChannel>[];
    final received = <String>[];
    var polls = 0;
    final client = AlertRealtimeClient(
      url: Uri.parse('ws://localhost/alerts'),
      readToken: () async => 'token',
      synchronize: () async => polls++,
      onAlert: (data) async =>
          received.add(data?['status'] as String? ?? 'none'),
      connect: (_) {
        final channel = FakeChannel();
        channels.add(channel);
        return channel;
      },
    );
    client.start();
    await tester.pump();
    channels.first.state({'status': 'PENDING'});
    await tester.pump();
    client.resume();
    await tester.pump();
    expect(channels.length, 2);
    expect(channels.first.sink.closed, isTrue);
    channels.last.state({'status': 'CANCELLED'});
    await tester.pump();
    expect(received, ['PENDING', 'CANCELLED']);
    client.stop();
    final before = polls;
    channels.last.state({'status': 'SOS_CREATED'});
    await tester.pump(const Duration(seconds: 5));
    expect(received, ['PENDING', 'CANCELLED']);
    expect(polls, before);
    for (final channel in channels) {
      unawaited(channel.incoming.close());
      await tester.pump();
    }
  });

  testWidgets('apply failure retains fallback until a new valid connection',
      (tester) async {
    final channel = FakeChannel();
    var polls = 0;
    final client = AlertRealtimeClient(
      url: Uri.parse('ws://localhost/alerts'),
      readToken: () async => 'token',
      synchronize: () async => polls++,
      onAlert: (_) async => throw const FormatException('bad alert'),
      connect: (_) => channel,
    );
    client.start();
    await tester.pump();
    channel.state({'status': 'invalid'});
    await tester.pump();
    expect(channel.sink.closed, isTrue);
    final before = polls;
    await tester.pump(const Duration(seconds: 1));
    expect(polls, greaterThan(before));
    client.stop();
    unawaited(channel.incoming.close());
    await tester.pump();
  });
}
