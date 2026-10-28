import 'flashlight_backend.dart';

FlashlightBackend createFlashlightBackend() => _UnsupportedBackend();

class _UnsupportedBackend extends FlashlightBackend {
  @override
  bool get isWeb => false;
  @override
  Future<CameraAccess> permission() async => CameraAccess.unknown;
  @override
  Future<void> open({required bool allowPermissionPrompt}) async {
    throw const FlashlightException(FlashlightIssue.unsupported);
  }

  @override
  Future<void> setTorch(bool enabled) async {}
  @override
  Future<void> close() async {}
  @override
  void dispose() {}
}
