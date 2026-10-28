import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian_ai/core/device/flashlight/flashlight_controller.dart';

class FakeFlashlightBackend extends FlashlightBackend {
  @override
  bool get isWeb => web;
  bool web = true;
  CameraAccess access = CameraAccess.prompt;
  FlashlightIssue? openError;
  FlashlightIssue? writeError;
  Completer<void>? pendingOpen;
  Completer<void>? pendingWrite;
  final writes = <bool>[];
  final prompts = <bool>[];
  int closes = 0;
  bool opened = false;
  int writesInFlight = 0;
  int maxWritesInFlight = 0;
  @override
  Future<CameraAccess> permission() async => access;
  @override
  Future<void> open({required bool allowPermissionPrompt}) async {
    prompts.add(allowPermissionPrompt);
    if (pendingOpen != null) await pendingOpen!.future;
    if (openError != null) throw FlashlightException(openError!);
    if (!allowPermissionPrompt && access != CameraAccess.granted) {
      throw const FlashlightException(FlashlightIssue.permissionRequired);
    }
    access = CameraAccess.granted;
    opened = true;
  }

  @override
  Future<void> setTorch(bool enabled) async {
    writesInFlight++;
    if (writesInFlight > maxWritesInFlight) maxWritesInFlight = writesInFlight;
    if (pendingWrite != null) await pendingWrite!.future;
    writesInFlight--;
    if (writeError != null) throw FlashlightException(writeError!);
    writes.add(enabled);
  }

  @override
  Future<void> close() async {
    closes++;
    opened = false;
  }

  @override
  void dispose() {}
}

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('preparation checks support without switching on and releases camera',
      () async {
    final backend = FakeFlashlightBackend();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    expect(await light.prepare(), isTrue);
    expect(light.cameraAccess, CameraAccess.granted);
    expect(light.support, FlashlightSupport.supported);
    expect(light.isStrobeActive, isFalse);
    expect(backend.writes, isEmpty);
    expect(backend.opened, isFalse);
  });

  test('permission denial never reports an active strobe', () async {
    final backend = FakeFlashlightBackend()
      ..openError = FlashlightIssue.permissionDenied;
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    expect(await light.toggleStrobe(), isFalse);
    expect(light.cameraAccess, CameraAccess.denied);
    expect(light.issue, FlashlightIssue.permissionDenied);
    expect(light.isStrobeActive, isFalse);
    expect(backend.opened, isFalse);
  });

  test('unsupported hardware has a distinct result', () async {
    final backend = FakeFlashlightBackend()
      ..openError = FlashlightIssue.unsupported;
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    expect(await light.prepare(), isFalse);
    expect(light.support, FlashlightSupport.unsupported);
    expect(light.isTorchOn, isFalse);
  });

  test('stop during permission request rejects late success', () async {
    final backend = FakeFlashlightBackend()..pendingOpen = Completer<void>();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    final starting = light.toggleStrobe();
    await flush();
    expect(light.isBusy, isTrue);
    final stopping = light.turnOff();
    backend.pendingOpen!.complete();
    await stopping;
    expect(await starting, isFalse);
    expect(backend.writes, isEmpty);
    expect(light.isStrobeActive, isFalse);
    expect(backend.opened, isFalse);
  });

  test('native stop waits for in-flight enable then closes hardware', () async {
    final backend = FakeFlashlightBackend()
      ..web = false
      ..pendingWrite = Completer<void>();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    final starting = light.toggleStrobe();
    await flush();
    final stopping = light.turnOff();
    backend.pendingWrite!.complete();
    await stopping;
    expect(await starting, isFalse);
    expect(backend.opened, isFalse);
    expect(light.isTorchOn, isFalse);
  });

  testWidgets('slow strobe writes cannot overlap and pulse failure stops mode',
      (tester) async {
    final backend = FakeFlashlightBackend();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.startStrobe(interval: const Duration(milliseconds: 50));
    expect(light.isStrobeActive, isTrue);
    backend.pendingWrite = Completer<void>();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(seconds: 1));
    expect(backend.writesInFlight, 1);
    expect(backend.maxWritesInFlight, 1);
    backend.writeError = FlashlightIssue.cameraBusy;
    backend.pendingWrite!.complete();
    await tester.pump();
    expect(light.isStrobeActive, isFalse);
    expect(light.issue, FlashlightIssue.cameraBusy);
    expect(backend.opened, isFalse);
    await light.turnOff();
  });

  test('automatic SOS does not request missing camera permission', () async {
    final backend = FakeFlashlightBackend();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.startStrobe(allowPermissionPrompt: false);
    expect(backend.prompts, [false]);
    expect(light.issue, FlashlightIssue.permissionRequired);
    expect(light.isStrobeActive, isFalse);
  });

  test('camera interruption updates all listeners and releases camera',
      () async {
    final backend = FakeFlashlightBackend();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.startStrobe();
    var notifications = 0;
    light.addListener(() {
      notifications++;
    });
    backend.onInterrupted!();
    await flush();
    expect(light.isStrobeActive, isFalse);
    expect(light.issue, FlashlightIssue.interrupted);
    expect(notifications, greaterThan(0));
    expect(backend.opened, isFalse);
  });

  test('restored login offers setup and later is remembered per browser',
      () async {
    final backend = FakeFlashlightBackend();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.beginSession('first-user');
    expect(light.shouldOfferSetup, isTrue);
    await light.dismissIntro();
    await light.beginSession(null);
    await light.beginSession('another-user');
    expect(light.shouldOfferSetup, isFalse);
    expect(light.cameraAccess, CameraAccess.prompt);
    expect(backend.prompts, isEmpty);
  });

  test(
      'login checks existing grant without opening camera; logout closes light',
      () async {
    final backend = FakeFlashlightBackend()..access = CameraAccess.granted;
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.beginSession('user');
    expect(backend.prompts, isEmpty);
    expect(light.cameraAccess, CameraAccess.granted);
    expect(light.shouldOfferSetup, isFalse);
    expect(backend.writes, isEmpty);
    await light.startStrobe();
    await light.beginSession(null);
    expect(backend.opened, isFalse);
    expect(light.isStrobeActive, isFalse);
    expect(light.cameraAccess, CameraAccess.unknown);
  });

  test('an immediate restart runs after stop cleanup', () async {
    final backend = FakeFlashlightBackend();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.startStrobe();
    final stop = light.turnOff();
    final restart = light.startStrobe();
    await Future.wait([stop, restart]);
    expect(light.isStrobeActive, isTrue);
    expect(backend.opened, isTrue);
    await light.turnOff();
  });

  test('initial login restoration preserves an already active SOS light',
      () async {
    final backend = FakeFlashlightBackend()..access = CameraAccess.granted;
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.startStrobe();
    await light.beginSession('restored-user');
    expect(light.isStrobeActive, isTrue);
    expect(backend.opened, isTrue);
    await light.turnOff();
  });

  test('refresh detects revoked permission without opening camera', () async {
    final backend = FakeFlashlightBackend();
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.prepare();
    backend.access = CameraAccess.denied;
    await light.refreshPermission();
    expect(light.cameraAccess, CameraAccess.denied);
    expect(light.support, FlashlightSupport.unknown);
    expect(backend.prompts, [true]);
  });

  test('successful setup survives reload without assuming permission is saved',
      () async {
    final firstBackend = FakeFlashlightBackend();
    final first = FlashlightController(backend: firstBackend);
    await first.beginSession('user');
    expect(first.shouldOfferSetup, isTrue);
    expect(await first.prepare(), isTrue);
    await flush();
    expect(first.shouldOfferSetup, isFalse);
    first.dispose();

    // A one-time browser grant has expired on the next visit. Remember only
    // onboarding completion; do not claim that camera access is still granted.
    final nextBackend = FakeFlashlightBackend();
    final next = FlashlightController(backend: nextBackend);
    addTearDown(next.dispose);
    await next.beginSession('user');
    expect(next.introDismissed, isTrue);
    expect(next.shouldOfferSetup, isFalse);
    expect(next.cameraAccess, CameraAccess.prompt);
    expect(nextBackend.prompts, isEmpty);
    await next.startStrobe(allowPermissionPrompt: false);
    expect(next.isStrobeActive, isFalse);
    expect(next.issue, FlashlightIssue.permissionRequired);
    expect(nextBackend.prompts, [false]);
  });

  test('restored permission hides intro without requiring torch support probe',
      () async {
    final backend = FakeFlashlightBackend()..access = CameraAccess.granted;
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.beginSession('user');
    expect(light.shouldOfferSetup, isFalse);
    expect(light.support, FlashlightSupport.unknown);
    expect(backend.opened, isFalse);
    expect(backend.prompts, isEmpty);
    expect(backend.closes, 0);
  });

  test('native success reports granted and remembers completed setup',
      () async {
    final backend = FakeFlashlightBackend()..web = false;
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.beginSession('user');
    expect(await light.prepare(), isTrue);
    expect(light.cameraAccess, CameraAccess.granted);
    expect(light.introDismissed, isTrue);
    expect(light.shouldOfferSetup, isFalse);
  });

  test('camera grant completes intro even if the device has no torch',
      () async {
    final backend = FakeFlashlightBackend()
      ..access = CameraAccess.granted
      ..openError = FlashlightIssue.unsupported;
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.beginSession('user');
    backend.onPermissionChanged!(CameraAccess.granted);
    expect(await light.prepare(), isFalse);
    expect(light.support, FlashlightSupport.unsupported);
    expect(light.introDismissed, isTrue);
    expect(light.shouldOfferSetup, isFalse);
    expect(light.isTorchOn, isFalse);
  });

  test(
      'revoked grant is checked without opening camera or repeating onboarding',
      () async {
    final backend = FakeFlashlightBackend()..access = CameraAccess.granted;
    final light = FlashlightController(backend: backend);
    addTearDown(light.dispose);
    await light.beginSession('user');
    backend.access = CameraAccess.denied;
    await light.refreshPermission();
    expect(light.cameraAccess, CameraAccess.denied);
    expect(light.shouldOfferSetup, isFalse);
    expect(backend.prompts, isEmpty);
    expect(light.isTorchOn, isFalse);
  });
}
