enum CameraAccess { unknown, prompt, granted, denied }

enum FlashlightSupport { unknown, supported, unsupported }

enum FlashlightIssue {
  permissionRequired,
  permissionDenied,
  unsupported,
  insecureContext,
  cameraMissing,
  cameraBusy,
  interrupted,
  timedOut,
  failed,
}

class FlashlightException implements Exception {
  const FlashlightException(this.issue);
  final FlashlightIssue issue;
}

/// Camera ownership belongs to the backend. close() also cancels pending opens.
abstract class FlashlightBackend {
  bool get isWeb;
  Future<CameraAccess> permission();
  Future<void> open({required bool allowPermissionPrompt});
  Future<void> setTorch(bool enabled);
  Future<void> close();
  void Function()? onInterrupted;
  void Function(CameraAccess access)? onPermissionChanged;
  void dispose();
}
