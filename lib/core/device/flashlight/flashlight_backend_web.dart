import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
import 'flashlight_backend.dart';

FlashlightBackend createFlashlightBackend() => _WebFlashlightBackend();

class _WebFlashlightBackend extends FlashlightBackend {
  web.MediaStream? _stream;
  web.MediaStreamTrack? _track;
  web.PermissionStatus? _permissionStatus;
  int _generation = 0;
  Completer<web.MediaStream>? _cancelPending;
  final List<void Function()> _removeListeners = [];

  _WebFlashlightBackend() {
    final hidden = ((web.Event event) {
      if (web.document.visibilityState != 'visible') _interrupt();
    }).toJS;
    final leaving = ((web.Event event) {
      _interrupt();
    }).toJS;
    web.document.addEventListener('visibilitychange', hidden);
    web.window.addEventListener('pagehide', leaving);
    _removeListeners.addAll([
      () => web.document.removeEventListener('visibilitychange', hidden),
      () => web.window.removeEventListener('pagehide', leaving),
    ]);
  }

  @override
  bool get isWeb => true;

  @override
  Future<CameraAccess> permission() async {
    if (!web.window.isSecureContext) return CameraAccess.unknown;
    try {
      final status = await web.window.navigator.permissions
          .query({'name': 'camera'}.jsify()! as JSObject)
          .toDart;
      _permissionStatus?.onchange = null;
      _permissionStatus = status;
      status.onchange = ((web.Event event) {
        final access = _access(status.state);
        if (access != CameraAccess.granted) _interrupt();
        onPermissionChanged?.call(access);
      }).toJS;
      return _access(status.state);
    } catch (_) {
      // Some browsers do not implement querying camera permissions.
      return CameraAccess.unknown;
    }
  }

  CameraAccess _access(String state) => switch (state) {
        'granted' => CameraAccess.granted,
        'denied' => CameraAccess.denied,
        _ => CameraAccess.prompt,
      };

  bool _supportsTorch(web.MediaStreamTrack track) {
    if (!track.hasProperty('getCapabilities'.toJS).toDart) return false;
    final value =
        track.getCapabilities().getProperty<JSAny?>('torch'.toJS)?.dartify();
    return value == true || (value is List && value.contains(true));
  }

  @override
  Future<void> open({required bool allowPermissionPrompt}) async {
    if (!web.window.isSecureContext) {
      throw const FlashlightException(FlashlightIssue.insecureContext);
    }
    if (!web.window.navigator.hasProperty('mediaDevices'.toJS).toDart) {
      throw const FlashlightException(FlashlightIssue.unsupported);
    }
    if (_track?.readyState == 'live') return;
    final generation = ++_generation;
    if (!allowPermissionPrompt && await permission() != CameraAccess.granted) {
      throw const FlashlightException(FlashlightIssue.permissionRequired);
    }
    if (generation != _generation) {
      throw const FlashlightException(FlashlightIssue.interrupted);
    }
    try {
      await _acquire(generation, {
        'facingMode': {'ideal': 'environment'}
      });
      if (!_supportsTorch(_track!)) {
        final currentId = _track!
            .getSettings()
            .getProperty<JSAny?>('deviceId'.toJS)
            ?.dartify();
        final devices =
            await web.window.navigator.mediaDevices.enumerateDevices().toDart;
        for (final device in devices.toDart) {
          if (generation != _generation) {
            throw const FlashlightException(FlashlightIssue.interrupted);
          }
          if (device.kind != 'videoinput' ||
              device.deviceId == currentId ||
              RegExp(r'front|user|face', caseSensitive: false)
                  .hasMatch(device.label)) {
            continue;
          }
          _stopStream();
          await _acquire(generation, {
            'deviceId': {'exact': device.deviceId}
          });
          if (_supportsTorch(_track!)) break;
        }
      }
      if (!_supportsTorch(_track!)) {
        throw const FlashlightException(FlashlightIssue.unsupported);
      }
      _track!.onended = ((web.Event event) {
        _interrupt();
      }).toJS;
    } on TimeoutException {
      await close();
      throw const FlashlightException(FlashlightIssue.timedOut);
    } catch (error) {
      // Do not close a newer request when an obsolete getUserMedia completes.
      if (generation == _generation) await close();
      if (error is FlashlightException) rethrow;
      String name;
      try {
        name = (error as JSObject).getProperty<JSString>('name'.toJS).toDart;
      } catch (_) {
        name = error.toString();
      }
      throw FlashlightException(switch (name) {
        'NotAllowedError' ||
        'SecurityError' =>
          FlashlightIssue.permissionDenied,
        'NotFoundError' ||
        'OverconstrainedError' =>
          FlashlightIssue.cameraMissing,
        'NotReadableError' || 'AbortError' => FlashlightIssue.cameraBusy,
        _ => FlashlightIssue.failed,
      });
    }
  }

  Future<void> _acquire(int generation, Map<String, Object> video) async {
    if (generation != _generation) {
      throw const FlashlightException(FlashlightIssue.interrupted);
    }
    final canceled = Completer<web.MediaStream>();
    _cancelPending = canceled;
    // Browser prompts cannot be dismissed. Obsolete streams are stopped even
    // when permission is granted after cancel, timeout, logout or a new request.
    final request = web.window.navigator.mediaDevices
        .getUserMedia(
          web.MediaStreamConstraints(video: video.jsify()!, audio: false.toJS),
        )
        .toDart
        .then((stream) {
      if (generation != _generation) {
        for (final track in stream.getTracks().toDart) {
          track.stop();
        }
        throw const FlashlightException(FlashlightIssue.interrupted);
      }
      return stream;
    });
    final stream = await Future.any([request, canceled.future])
        .timeout(const Duration(seconds: 20));
    if (identical(_cancelPending, canceled)) _cancelPending = null;
    if (generation != _generation) {
      for (final track in stream.getTracks().toDart) {
        track.stop();
      }
      throw const FlashlightException(FlashlightIssue.interrupted);
    }
    _stream = stream;
    final tracks = stream.getVideoTracks().toDart;
    if (tracks.isEmpty) {
      throw const FlashlightException(FlashlightIssue.cameraMissing);
    }
    _track = tracks.first;
    // A successful camera grant also completes setup on devices without a
    // torch. Unsupported hardware must not lead to a repeated permission intro.
    onPermissionChanged?.call(CameraAccess.granted);
  }

  @override
  Future<void> setTorch(bool enabled) async {
    final track = _track;
    if (track == null || track.readyState != 'live') {
      throw const FlashlightException(FlashlightIssue.interrupted);
    }
    await track
        .applyConstraints(web.MediaTrackConstraints(
          advanced: [web.MediaTrackConstraintSet(torch: enabled.toJS)].toJS,
        ))
        .toDart;
    final actual =
        track.getSettings().getProperty<JSAny?>('torch'.toJS)?.dartify();
    if (actual is bool && actual != enabled) {
      throw const FlashlightException(FlashlightIssue.failed);
    }
  }

  void _interrupt() {
    unawaited(close());
    onInterrupted?.call();
  }

  @override
  Future<void> close() async {
    ++_generation;
    final canceled = _cancelPending;
    _cancelPending = null;
    if (canceled != null && !canceled.isCompleted) {
      canceled.completeError(
          const FlashlightException(FlashlightIssue.interrupted));
    }
    _stopStream();
  }

  void _stopStream() {
    final stream = _stream;
    _stream = null;
    _track = null;
    if (stream != null) {
      for (final track in stream.getTracks().toDart) {
        track.onended = null;
        track.stop();
      }
    }
  }

  @override
  void dispose() {
    _permissionStatus?.onchange = null;
    _permissionStatus = null;
    for (final remove in _removeListeners) {
      remove();
    }
    unawaited(close());
  }
}
