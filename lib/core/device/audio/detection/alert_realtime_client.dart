import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Read-only audio updates. HTTP remains the fallback and the action channel.
class AlertRealtimeClient {
  AlertRealtimeClient({
    required this.url,
    required this.readToken,
    required this.onAlert,
    required this.synchronize,
    WebSocketChannel Function(Uri)? connect,
    DateTime Function()? now,
    this.tickInterval = const Duration(seconds: 1),
    this.silenceTimeout = const Duration(seconds: 5),
    this.stateTimeout = const Duration(seconds: 90),
    this.reconnectBase = const Duration(seconds: 1),
  })  : _connect = connect ?? WebSocketChannel.connect,
        _now = now ?? DateTime.now;

  final Uri url;
  final Future<String?> Function() readToken;
  final Future<void> Function(Map<dynamic, dynamic>?) onAlert;
  final Future<void> Function() synchronize;
  final WebSocketChannel Function(Uri) _connect;
  final DateTime Function() _now;
  final Duration tickInterval, silenceTimeout, stateTimeout, reconnectBase;
  Timer? _timer, _retry;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _running = false, _healthy = false, _connecting = false;
  bool _syncing = false;
  int _epoch = 0, _failures = 0;
  DateTime? _lastFrame, _lastState;
  Future<void> _applying = Future.value();

  static Uri streamUrl(String apiBaseUrl) {
    final base = Uri.parse(apiBaseUrl);
    return Uri(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      host: base.host,
      port: base.hasPort ? base.port : null,
      path:
          '${base.path.replaceFirst(RegExp(r'/+$'), '')}/detection/alerts/stream',
    );
  }

  void start() {
    if (_running) return;
    _running = true;
    _timer = Timer.periodic(tickInterval, (_) => _tick());
    unawaited(_open());
  }

  void resume() {
    if (!_running) return;
    // Resuming a suspended browser/mobile process always reloads server state.
    _drop(_epoch, retry: false);
    _retry?.cancel();
    unawaited(_open());
  }

  void _tick() {
    if (!_running) return;
    final now = _now();
    if (_healthy &&
        (now.difference(_lastFrame!) > silenceTimeout ||
            now.difference(_lastState!) > stateTimeout)) {
      _drop(_epoch);
    }
    if (!_healthy) unawaited(_synchronize());
  }

  Future<void> _synchronize() async {
    if (_syncing || !_running) return;
    _syncing = true;
    try {
      await synchronize();
    } catch (_) {
      // The durable server timer continues while the network is unavailable.
    } finally {
      _syncing = false;
    }
  }

  Future<void> _open() async {
    if (!_running || _connecting) return;
    _connecting = true;
    final epoch = ++_epoch;
    try {
      // Existing HTTP interceptor can refresh an expired access token first.
      await _synchronize();
      final token = await readToken();
      if (!_running || epoch != _epoch) return;
      if (token == null || token.isEmpty || token == 'offline_session_token') {
        throw StateError('No access token');
      }
      final channel = _channel = _connect(url);
      _subscription = channel.stream.listen(
        (message) => _message(message, epoch),
        onDone: () => _drop(epoch),
        onError: (Object error) => _drop(epoch),
        cancelOnError: true,
      );
      await channel.ready.timeout(const Duration(seconds: 8));
      if (!_running || epoch != _epoch) return;
      channel.sink.add(jsonEncode({'type': 'AUTH', 'token': token}));
      // Until the first state arrives HTTP polling stays enabled.
      _retry?.cancel();
      _retry = Timer(silenceTimeout, () {
        if (!_healthy) _drop(epoch);
      });
    } catch (_) {
      _drop(epoch);
    } finally {
      _connecting = false;
      // A lifecycle resume can invalidate a still-opening socket.
      if (_running && epoch != _epoch && _retry?.isActive != true) {
        unawaited(_open());
      }
    }
  }

  void _message(dynamic raw, int epoch) {
    if (!_running || epoch != _epoch) return;
    try {
      final message = jsonDecode(raw as String) as Map<String, dynamic>;
      _lastFrame = _now();
      if (message['type'] == 'AUDIO_ALERT') {
        final data = message['data'];
        if (data != null && data is! Map) throw const FormatException();
        _lastState = _lastFrame;
        _healthy = true;
        _failures = 0;
        _retry?.cancel();
        // Apply in order; a previous session's queued callback cannot leak
        // through logout, reconnect or switching accounts.
        _applying = _applying.then((_) async {
          if (_running && epoch == _epoch) await onAlert(data as Map?);
        }).catchError((Object error) {
          _drop(epoch);
        });
      } else if (message['type'] != 'HEARTBEAT' && message['type'] != 'PONG') {
        throw const FormatException();
      }
    } catch (_) {
      _drop(epoch);
    }
  }

  void _drop(int epoch, {bool retry = true}) {
    if (epoch != _epoch) return;
    ++_epoch;
    _healthy = false;
    final channel = _channel;
    if (_subscription != null) unawaited(_subscription!.cancel());
    _subscription = null;
    _channel = null;
    if (channel != null) unawaited(channel.sink.close());
    _retry?.cancel();
    if (_running && retry) {
      final multiplier = min(30, pow(2, min(_failures++, 5)).toInt());
      _retry = Timer(reconnectBase * multiplier, () => unawaited(_open()));
    }
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _retry?.cancel();
    _drop(_epoch, retry: false);
  }
}
