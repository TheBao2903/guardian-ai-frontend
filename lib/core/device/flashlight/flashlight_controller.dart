import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flashlight_backend.dart';
import 'flashlight_backend_stub.dart'
    if (dart.library.io) 'flashlight_backend_io.dart'
    if (dart.library.js_interop) 'flashlight_backend_web.dart' as platform;
export 'flashlight_backend.dart';

final flashlightControllerProvider =
    ChangeNotifierProvider<FlashlightController>(
  (ref) => FlashlightController(),
);

/// Shared by Home, SOS and settings. Commands are serialized; stop invalidates
/// pending opens immediately so a late permission grant cannot turn the light on.
class FlashlightController extends ChangeNotifier {
  FlashlightController({FlashlightBackend? backend})
      : _backend = backend ?? platform.createFlashlightBackend() {
    _backend.onPermissionChanged = (access) {
      if (_disposed) return;
      cameraAccess = access;
      if (access != CameraAccess.granted) {
        support = FlashlightSupport.unknown;
        issue = access == CameraAccess.denied
            ? FlashlightIssue.permissionDenied
            : FlashlightIssue.permissionRequired;
      }
      _emit();
    };
    _backend.onInterrupted = () {
      if (isBusy || _isTorchOn || _isStrobeActive) {
        unawaited(_stop(issue: FlashlightIssue.interrupted));
      }
    };
  }

  static const _dismissedKey = 'guardian_flashlight_intro_seen_v1';
  final FlashlightBackend _backend;
  CameraAccess cameraAccess = CameraAccess.unknown;
  FlashlightSupport support = FlashlightSupport.unknown;
  FlashlightIssue? issue;
  bool isBusy = false;
  bool introDismissed = true;
  bool _isTorchOn = false;
  bool _isStrobeActive = false;
  bool _disposed = false;
  int _generation = 0;
  String? _session;
  Timer? _timer;
  Future<void> _queue = Future<void>.value();

  bool get isWeb => _backend.isWeb;
  bool get isTorchOn => _isTorchOn;
  bool get isStrobeActive => _isStrobeActive;
  bool get shouldOfferSetup =>
      !introDismissed &&
      (cameraAccess != CameraAccess.granted ||
          isBusy ||
          support != FlashlightSupport.supported);

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  bool _current(int generation) => !_disposed && generation == _generation;

  Future<void> _enqueue(Future<void> Function() command) {
    final next = _queue.then((_) => command());
    _queue = next.catchError((Object error, StackTrace stack) {
      debugPrint('Flashlight command failed: $error');
    });
    return next;
  }

  Future<void> beginSession(String? userId) async {
    if (_session == userId) return;
    final previousSession = _session;
    _session = userId;
    introDismissed = true;
    // Initial session restoration can race an incoming SOS. Preserve its light.
    if (previousSession != null || userId == null) await turnOff();
    final generation = _generation;
    if (!_current(generation) || _session != userId) return;
    if (!isBusy && !_isStrobeActive && !_isTorchOn) {
      cameraAccess = CameraAccess.unknown;
      support = FlashlightSupport.unknown;
      issue = null;
    }
    _emit();
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (!_current(generation) || _session != userId) return;
    introDismissed = prefs.getBool(_dismissedKey) ?? false;
    cameraAccess = await _backend.permission();
    if (!_current(generation) || _session != userId) return;
    _emit();
    if (cameraAccess == CameraAccess.granted) {
      await prepare(allowPermissionPrompt: false);
    }
  }

  Future<void> dismissIntro() async {
    introDismissed = true;
    _emit();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissedKey, true);
  }

  Future<void> refreshPermission() async {
    if (isBusy) return;
    final generation = _generation;
    final access = await _backend.permission();
    if (!_current(generation)) return;
    cameraAccess = access;
    // A cached support result is not proof that a new camera open will work.
    if (access != CameraAccess.granted) support = FlashlightSupport.unknown;
    _emit();
  }

  Future<bool> prepare({bool allowPermissionPrompt = true}) => _start(
      probeOnly: true,
      strobe: false,
      allowPermissionPrompt: allowPermissionPrompt);

  Future<void> enableTorch() async {
    await _start(probeOnly: false, strobe: false, allowPermissionPrompt: true);
  }

  Future<void> startStrobe({
    Duration interval = const Duration(milliseconds: 350),
    bool allowPermissionPrompt = true,
  }) async {
    // Emergency activation takes precedence over a setup probe.
    if (isBusy) await turnOff();
    await _start(
        probeOnly: false,
        strobe: true,
        allowPermissionPrompt: allowPermissionPrompt,
        interval: interval);
  }

  Future<bool> _start({
    required bool probeOnly,
    required bool strobe,
    required bool allowPermissionPrompt,
    Duration interval = const Duration(milliseconds: 350),
  }) async {
    if (_disposed || isBusy) return false;
    if (!probeOnly && _isStrobeActive && strobe) return true;
    if (probeOnly && (_isStrobeActive || _isTorchOn)) return true;
    final generation = ++_generation;
    _timer?.cancel();
    isBusy = true;
    issue = null;
    _isStrobeActive = false;
    _emit();
    var success = false;
    await _enqueue(() async {
      if (!_current(generation)) return;
      try {
        await _backend.open(allowPermissionPrompt: allowPermissionPrompt);
        if (!_current(generation)) {
          await _backend.close();
          return;
        }
        if (isWeb) cameraAccess = CameraAccess.granted;
        support = FlashlightSupport.supported;
        if (probeOnly) {
          await _backend.close();
        } else {
          await _backend.setTorch(true);
          if (!_current(generation)) {
            await _backend.close();
            return;
          }
          _isTorchOn = true;
          _isStrobeActive = strobe;
          if (strobe) _schedulePulse(generation, interval);
        }
        success = true;
      } catch (error) {
        await _closeSafely();
        if (_current(generation)) {
          _recordError(error);
          if (isWeb && support == FlashlightSupport.unsupported) {
            cameraAccess = await _backend.permission();
          }
        }
      } finally {
        if (_current(generation)) {
          isBusy = false;
          _emit();
        }
      }
    });
    return success && _current(generation);
  }

  void _schedulePulse(int generation, Duration interval) {
    _timer = Timer(interval, () {
      unawaited(_enqueue(() async {
        if (!_current(generation) || !_isStrobeActive) return;
        try {
          final next = !_isTorchOn;
          await _backend.setTorch(next);
          if (!_current(generation)) return;
          _isTorchOn = next;
          // UI reflects the strobe mode, not each individual pulse.
          _schedulePulse(generation, interval);
        } catch (error) {
          await _closeSafely();
          if (_current(generation)) {
            _recordError(error);
            _emit();
          }
        }
      }));
    });
  }

  void _recordError(Object error) {
    issue = error is FlashlightException ? error.issue : FlashlightIssue.failed;
    _isTorchOn = false;
    _isStrobeActive = false;
    if (issue == FlashlightIssue.permissionDenied) {
      cameraAccess = CameraAccess.denied;
    }
    if (issue == FlashlightIssue.permissionRequired) {
      cameraAccess = CameraAccess.prompt;
    }
    if (issue == FlashlightIssue.unsupported ||
        issue == FlashlightIssue.cameraMissing) {
      support = FlashlightSupport.unsupported;
    }
  }

  Future<void> _closeSafely() async {
    try {
      await _backend.close();
    } catch (error) {
      debugPrint('Flashlight cleanup failed: $error');
    }
  }

  Future<void> _stop({FlashlightIssue? issue}) async {
    ++_generation;
    _timer?.cancel();
    _timer = null;
    isBusy = false;
    _isTorchOn = false;
    _isStrobeActive = false;
    this.issue = issue;
    // Queue cleanup before notifying listeners or yielding. An immediate
    // restart must run after this stop, otherwise cleanup could close its camera.
    final immediateClose = isWeb ? _closeSafely() : Future<void>.value();
    final queuedClose = _enqueue(_closeSafely);
    _emit();
    await immediateClose;
    await queuedClose;
  }

  Future<void> turnOff() => _stop();
  Future<void> disableTorch() => turnOff();
  Future<bool> toggleTorch() async {
    if (isBusy) return false;
    if (_isTorchOn && !_isStrobeActive) {
      await turnOff();
      return false;
    }
    return _start(probeOnly: false, strobe: false, allowPermissionPrompt: true);
  }

  Future<bool> toggleStrobe() async {
    if (isBusy || _isStrobeActive || _isTorchOn) {
      await turnOff();
      return false;
    }
    return _start(probeOnly: false, strobe: true, allowPermissionPrompt: true);
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _timer?.cancel();
    _backend.onInterrupted = null;
    _backend.onPermissionChanged = null;
    if (isWeb) {
      _backend.dispose();
    } else {
      // Native cleanup waits for in-flight enable before disabling again.
      unawaited(_enqueue(() async {
        await _closeSafely();
        _backend.dispose();
      }));
    }
    super.dispose();
  }
}
