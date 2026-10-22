/// Permission Service - Handle runtime permissions
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'recording/microphone_permission_service.dart';

/// ============================================================================
/// FILE: permission_service.dart
/// MODULE: Device - Runtime Permission Handler
/// ROLE:
///   Handle all runtime permissions for the app:
///   - Microphone (audio recording)
///   - Location (SOS)
///   - Camera (flashlight)
///   - Storage (optional - for saving clips)
/// ============================================================================

/// Permission status
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  unknown,
}

/// Map permission_handler status to our status
AppPermissionStatus _mapStatus(ph.PermissionStatus status) {
  switch (status) {
    case ph.PermissionStatus.granted:
      return AppPermissionStatus.granted;
    case ph.PermissionStatus.denied:
      return AppPermissionStatus.denied;
    case ph.PermissionStatus.permanentlyDenied:
      return AppPermissionStatus.permanentlyDenied;
    case ph.PermissionStatus.restricted:
      return AppPermissionStatus.restricted;
    case ph.PermissionStatus.limited:
      return AppPermissionStatus.limited;
    default:
      return AppPermissionStatus.unknown;
  }
}

/// Permission service
class PermissionService {
  /// Check microphone permission
  Future<bool> checkMicrophone() async {
    try {
      final status = await ph.Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('PermissionService: Error checking microphone - $e');
      return false;
    }
  }

  /// Request microphone permission
  Future<AppPermissionStatus> requestMicrophone() async {
    try {
      final status = await ph.Permission.microphone.request();
      return _mapStatus(status);
    } catch (e) {
      debugPrint('PermissionService: Error requesting microphone - $e');
      return AppPermissionStatus.unknown;
    }
  }

  /// Check location permission
  Future<bool> checkLocation() async {
    try {
      final status = await ph.Permission.locationWhenInUse.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('PermissionService: Error checking location - $e');
      return false;
    }
  }

  /// Request location permission
  Future<AppPermissionStatus> requestLocation() async {
    try {
      final status = await ph.Permission.locationWhenInUse.request();
      return _mapStatus(status);
    } catch (e) {
      debugPrint('PermissionService: Error requesting location - $e');
      return AppPermissionStatus.unknown;
    }
  }

  /// Check notification permission (Android 13+)
  Future<bool> checkNotification() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await ph.Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('PermissionService: Error checking notification - $e');
      return false;
    }
  }

  /// Request notification permission (Android 13+)
  Future<AppPermissionStatus> requestNotification() async {
    if (!Platform.isAndroid) return AppPermissionStatus.granted;

    try {
      final status = await ph.Permission.notification.request();
      return _mapStatus(status);
    } catch (e) {
      debugPrint('PermissionService: Error requesting notification - $e');
      return AppPermissionStatus.unknown;
    }
  }

  /// Open app settings
  Future<bool> openSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      debugPrint('PermissionService: Error opening settings - $e');
      return false;
    }
  }

  /// Request all required permissions at once
  Future<Map<String, AppPermissionStatus>> requestAllPermissions() async {
    final results = <String, AppPermissionStatus>{};

    // Request microphone
    results['microphone'] = await requestMicrophone();

    // Request location
    results['location'] = await requestLocation();

    // Request notification (Android 13+)
    if (Platform.isAndroid) {
      results['notification'] = await requestNotification();
    }

    return results;
  }

  /// Check if all required permissions are granted
  Future<bool> hasAllPermissions() async {
    final mic = await checkMicrophone();
    final location = await checkLocation();
    return mic && location;
  }
}

/// Provider for permission service
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// Provider for microphone permission state
final microphonePermissionProvider =
    FutureProvider<MicrophonePermissionState>((ref) async {
  final service = ref.read(permissionServiceProvider);
  final hasPermission = await service.checkMicrophone();

  if (hasPermission) {
    return MicrophonePermissionState.granted;
  } else {
    return MicrophonePermissionState.denied;
  }
});
