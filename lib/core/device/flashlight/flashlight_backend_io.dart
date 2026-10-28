import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';
import 'flashlight_backend.dart';

FlashlightBackend createFlashlightBackend() => _NativeFlashlightBackend();

class _NativeFlashlightBackend extends FlashlightBackend {
  bool _opened = false;

  @override
  bool get isWeb => false;

  @override
  Future<CameraAccess> permission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return CameraAccess.unknown;
    }
    try {
      final status = await Permission.camera.status;
      if (status.isGranted || status.isLimited) {
        return CameraAccess.granted;
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        return CameraAccess.denied;
      } else {
        return CameraAccess.prompt;
      }
    } catch (e) {
      debugPrint('Error checking camera permission on native: $e');
      return CameraAccess.unknown;
    }
  }

  @override
  Future<void> open({required bool allowPermissionPrompt}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw const FlashlightException(FlashlightIssue.unsupported);
    }

    // 1. Kiểm tra và xin quyền Camera trên iOS / Android nếu chưa có
    var access = await permission();
    if (access != CameraAccess.granted) {
      if (allowPermissionPrompt) {
        try {
          final reqStatus = await Permission.camera.request();
          if (reqStatus.isGranted || reqStatus.isLimited) {
            access = CameraAccess.granted;
            onPermissionChanged?.call(CameraAccess.granted);
          } else if (reqStatus.isPermanentlyDenied || reqStatus.isRestricted) {
            onPermissionChanged?.call(CameraAccess.denied);
            throw const FlashlightException(FlashlightIssue.permissionDenied);
          } else {
            onPermissionChanged?.call(CameraAccess.denied);
            throw const FlashlightException(FlashlightIssue.permissionRequired);
          }
        } catch (e) {
          if (e is FlashlightException) rethrow;
          throw const FlashlightException(FlashlightIssue.permissionRequired);
        }
      } else {
        throw const FlashlightException(FlashlightIssue.permissionRequired);
      }
    }

    // 2. Kiểm tra khả năng hỗ trợ Torch của phần cứng (sau khi đã được cấp quyền)
    try {
      final isAvailable = await TorchLight.isTorchAvailable();
      if (!isAvailable) {
        throw const FlashlightException(FlashlightIssue.unsupported);
      }
    } catch (e) {
      if (e is FlashlightException) rethrow;
      throw const FlashlightException(FlashlightIssue.unsupported);
    }

    _opened = true;
  }

  @override
  Future<void> setTorch(bool enabled) async {
    try {
      if (enabled) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }
    } on EnableTorchExistentUserException {
      throw const FlashlightException(FlashlightIssue.cameraBusy);
    } on EnableTorchNotAvailableException {
      throw const FlashlightException(FlashlightIssue.unsupported);
    } catch (e) {
      debugPrint('Error setting torch: $e');
      throw const FlashlightException(FlashlightIssue.failed);
    }
  }

  @override
  Future<void> close() async {
    if (!_opened) return;
    _opened = false;
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(close());
  }
}
