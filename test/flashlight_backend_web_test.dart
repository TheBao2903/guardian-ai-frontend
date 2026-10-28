@TestOn('browser')
library;

import 'dart:js_interop';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/device/flashlight/flashlight_backend.dart';
import 'package:guardian_ai/core/device/flashlight/flashlight_backend_web.dart';

@JS('eval')
external JSAny? _eval(JSString source);
void js(String source) {
  _eval(source.toJS);
}

int count(String expression) => (_eval(expression.toJS) as JSNumber).toDartInt;

void main() {
  setUp(() {
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
  });

  test('actual browser interop acquires, toggles and releases camera',
      () async {
    final backend = createFlashlightBackend();
    addTearDown(backend.dispose);
    expect(await backend.permission(), CameraAccess.granted);
    await backend.open(allowPermissionPrompt: false);
    await backend.setTorch(true);
    expect(count('Number(flashMock.enabled)'), 1);
    await backend.setTorch(false);
    expect(count('Number(flashMock.enabled)'), 0);
    await backend.close();
    expect(count('flashMock.stops'), 1);
  });

  test('unavailable torch closes camera and reports unsupported', () async {
    js('flashMock.support = false;');
    final backend = createFlashlightBackend();
    addTearDown(backend.dispose);
    await expectLater(
        backend.open(allowPermissionPrompt: true),
        throwsA(isA<FlashlightException>()
            .having((e) => e.issue, 'issue', FlashlightIssue.unsupported)));
    expect(count('flashMock.stops'), 1);
  });

  test('missing permission in automatic SOS never opens camera', () async {
    js("flashMock.permission = 'prompt';");
    final backend = createFlashlightBackend();
    addTearDown(backend.dispose);
    await expectLater(
        backend.open(allowPermissionPrompt: false),
        throwsA(isA<FlashlightException>().having(
            (e) => e.issue, 'issue', FlashlightIssue.permissionRequired)));
    expect(count('flashMock.opens'), 0);
  });

  test('permission denial is mapped from the JavaScript DOMException',
      () async {
    js("flashMock.reject = 'NotAllowedError';");
    final backend = createFlashlightBackend();
    addTearDown(backend.dispose);
    await expectLater(
        backend.open(allowPermissionPrompt: true),
        throwsA(isA<FlashlightException>().having(
            (e) => e.issue, 'issue', FlashlightIssue.permissionDenied)));
  });

  test('cancel resolves immediately and cleans a late permission grant',
      () async {
    js('flashMock.pending = true;');
    final backend = createFlashlightBackend();
    addTearDown(backend.dispose);
    final opening = backend.open(allowPermissionPrompt: true);
    final result = expectLater(opening, throwsA(isA<FlashlightException>()));
    await Future<void>.delayed(Duration.zero);
    await backend.close();
    await result;
    js('flashMock.resolve();');
    await Future<void>.delayed(Duration.zero);
    expect(count('flashMock.stops'), 1);
  });

  test('track ended interrupts and closes camera', () async {
    final backend = createFlashlightBackend();
    addTearDown(backend.dispose);
    var interrupted = false;
    backend.onInterrupted = () {
      interrupted = true;
    };
    await backend.open(allowPermissionPrompt: true);
    js('flashMock.ended();');
    expect(interrupted, isTrue);
    expect(count('flashMock.stops'), 1);
  });
}
