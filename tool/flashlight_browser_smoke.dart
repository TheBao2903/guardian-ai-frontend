import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:guardian_ai/core/device/flashlight/flashlight_backend.dart';
import 'package:guardian_ai/core/device/flashlight/flashlight_backend_web.dart';

@JS('eval')
external JSAny? _eval(JSString source);
void js(String source) {
  _eval(source.toJS);
}

int count(String expression) => (_eval(expression.toJS) as JSNumber).toDartInt;
void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> rejects(Future<void> operation, FlashlightIssue issue) async {
  try {
    await operation;
  } on FlashlightException catch (error) {
    check(error.issue == issue, 'Expected $issue, got ${error.issue}');
    return;
  }
  throw StateError('Expected $issue');
}

void reset() {
  js(r'''
      window.flashMock = { stops: 0, opens: 0, enabled: false,
        permission: 'granted', support: true, pending: false, reject: null,
        resolve: null, ended: null };
      const m = window.flashMock;
      Object.defineProperty(navigator, 'permissions', { configurable: true,
        value: { query: async () => ({ state: m.permission }) } });
      Object.defineProperty(navigator, 'mediaDevices', { configurable: true,
        value: { enumerateDevices: async () => [], getUserMedia: async options => {
          m.opens++;
          if (options.audio !== false) throw new Error('Audio must not be requested');
          if (m.reject) throw new DOMException('mock', m.reject);
          const track = { readyState: 'live', onended: null,
            getCapabilities: () => ({ torch: m.support ? [true, false] : [false] }),
            getSettings: () => ({ torch: m.enabled }),
            applyConstraints: async c => { m.enabled = c.advanced[0].torch; },
            stop: () => { m.stops++; track.readyState = 'ended'; m.enabled = false; }
          };
          m.ended = () => { track.readyState = 'ended'; if(track.onended) track.onended(new Event('ended')); };
          const stream = { getTracks: () => [track], getVideoTracks: () => [track] };
          if (m.pending) return await new Promise(resolve => { m.resolve = () => resolve(stream); });
          return stream;
        } } });
    ''');
}

Future<void> main() async {
  final results = <String>[];
  Future<void> run(
      String name, Future<void> Function(FlashlightBackend) body) async {
    reset();
    final backend = createFlashlightBackend();
    try {
      await body(backend);
      results.add('PASS: $name');
    } finally {
      backend.dispose();
    }
  }

  try {
    await run('camera access, torch constraints and release', (backend) async {
      check(await backend.permission() == CameraAccess.granted, 'permission');
      await backend.open(allowPermissionPrompt: false);
      await backend.setTorch(true);
      check(count('Number(flashMock.enabled)') == 1, 'torch on');
      await backend.setTorch(false);
      check(count('Number(flashMock.enabled)') == 0, 'torch off');
      await backend.close();
      check(count('flashMock.stops') == 1, 'release');
    });
    await run('unsupported torch releases camera', (backend) async {
      CameraAccess? observed;
      backend.onPermissionChanged = (access) => observed = access;
      js('flashMock.support = false');
      await rejects(backend.open(allowPermissionPrompt: true),
          FlashlightIssue.unsupported);
      check(count('flashMock.stops') == 1, 'release unsupported');
      check(observed == CameraAccess.granted,
          'camera grant must be reported even without torch');
    });
    await run('automatic SOS does not prompt', (backend) async {
      js("flashMock.permission = 'prompt'");
      await rejects(backend.open(allowPermissionPrompt: false),
          FlashlightIssue.permissionRequired);
      check(count('flashMock.opens') == 0, 'unexpected open');
    });
    await run('DOMException permission denial', (backend) async {
      js("flashMock.reject = 'NotAllowedError'");
      await rejects(backend.open(allowPermissionPrompt: true),
          FlashlightIssue.permissionDenied);
    });
    await run('cancel and late camera grant', (backend) async {
      js('flashMock.pending = true');
      final operation = rejects(backend.open(allowPermissionPrompt: true),
          FlashlightIssue.interrupted);
      await Future<void>.delayed(Duration.zero);
      await backend.close();
      await operation;
      js('flashMock.resolve()');
      await Future<void>.delayed(Duration.zero);
      check(count('flashMock.stops') == 1, 'late stream leaked');
    });
    await run('camera ended event', (backend) async {
      var interrupted = false;
      backend.onInterrupted = () {
        interrupted = true;
      };
      await backend.open(allowPermissionPrompt: true);
      js('flashMock.ended()');
      check(interrupted && count('flashMock.stops') == 1, 'ended cleanup');
    });
    await run('other rear camera can supply torch', (backend) async {
      js(r'''
        flashMock.support = false;
        navigator.mediaDevices.enumerateDevices = async () => [
          { kind: 'videoinput', deviceId: 'rear-main', label: 'Back camera' }
        ];
        const original = navigator.mediaDevices.getUserMedia;
        navigator.mediaDevices.getUserMedia = async options => {
          if (options.video.deviceId) flashMock.support = true;
          return original(options);
        };
      ''');
      await backend.open(allowPermissionPrompt: true);
      check(count('flashMock.opens') == 2 && count('flashMock.stops') == 1,
          'camera fallback');
      await backend.setTorch(true);
    });
    web.document.body!.textContent =
        '${results.join('\n')}\nAll ${results.length} browser checks passed.';
    web.document.body!.setAttribute('data-result', 'passed');
  } catch (error, stack) {
    web.document.body!.textContent =
        '${results.join('\n')}\nFAIL: $error\n$stack';
    web.document.body!.setAttribute('data-result', 'failed');
  }
}
