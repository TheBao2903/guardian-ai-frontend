/// Microphone Permission Service
library;

///   Quản lý quyền microphone theo yêu cầu:
///
///   1. KHÔNG tự động yêu cầu khi app khởi chạy
///   2. Chỉ hỏi khi người dùng bật tính năng phát hiện âm thanh
///   3. Cung cấp trạng thái quyền để UI hiển thị phù hợp
///
///   Tuân thủ nguyên tắc:
///
///   - Privacy by design: Không thu âm khi chưa có consent
///   - Platform policies: iOS (limited background), Android (foreground service)
///   - Graceful degradation: Tính năng SOS không phụ thuộc microphone
///
/// CONNECTIONS / DEPENDENCIES:
///   - permission_handler: Quản lý runtime permissions
///   - Riverpod: State management
///
/// PLATFORM CONSTRAINTS:
///   - iOS: AVAudioSession requires background mode config
///   - Android: RECORD_AUDIO permission + foreground service
///   - Web: MediaDevices.getUserMedia (no background)
///
/// STATE:
///   - granted: Microphone có quyền
///   - denied: User từ chối (có thể hỏi lại)
///   - permanentlyDenied: User từ chối vĩnh viễn (cần settings)
///   - unknown: Chưa hỏi
/// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Permission state enum
enum MicrophonePermissionState {
  unknown,
  granted,
  denied,
  permanentlyDenied,
}

// Provider for microphone permission state
final microphonePermissionProvider = StateNotifierProvider<
    MicrophonePermissionNotifier, MicrophonePermissionState>(
  (ref) => MicrophonePermissionNotifier(),
);

class MicrophonePermissionNotifier
    extends StateNotifier<MicrophonePermissionState> {
  MicrophonePermissionNotifier() : super(MicrophonePermissionState.unknown) {
    _checkCurrentStatus();
  }

  /// Check current permission status without requesting
  Future<void> _checkCurrentStatus() async {
    if (kIsWeb) {
      // Web: always granted via browser prompt
      state = MicrophonePermissionState.granted;
      return;
    }

    final status = await Permission.microphone.status;
    _updateState(status);
  }

  /// Request microphone permission
  /// NOTE: Chỉ gọi khi user chủ động bật tính năng phát hiện âm thanh
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      // Web: browser will prompt, assume granted for now
      state = MicrophonePermissionState.granted;
      return true;
    }

    final status = await Permission.microphone.request();
    _updateState(status);

    return state == MicrophonePermissionState.granted;
  }

  /// Open app settings for user to manually enable permission
  /// Use when permission is permanently denied
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Check if permission can be requested
  bool get canRequest {
    return state == MicrophonePermissionState.unknown ||
        state == MicrophonePermissionState.denied;
  }

  /// Check if permission is permanently denied
  bool get isPermanentlyDenied {
    return state == MicrophonePermissionState.permanentlyDenied;
  }

  /// Refresh permission status
  Future<void> refresh() async {
    await _checkCurrentStatus();
  }

  void _updateState(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        state = MicrophonePermissionState.granted;
      case PermissionStatus.denied:
        state = MicrophonePermissionState.denied;
      case PermissionStatus.permanentlyDenied:
        state = MicrophonePermissionState.permanentlyDenied;
      case PermissionStatus.restricted:
      case PermissionStatus.provisional:
        state = MicrophonePermissionState.denied;
    }
  }
}

// Extension for readable messages
extension MicrophonePermissionStateExtension on MicrophonePermissionState {
  String get displayName {
    switch (this) {
      case MicrophonePermissionState.unknown:
        return 'Chưa yêu cầu';
      case MicrophonePermissionState.granted:
        return 'Đã cho phép';
      case MicrophonePermissionState.denied:
        return 'Đã từ chối';
      case MicrophonePermissionState.permanentlyDenied:
        return 'Từ chối vĩnh viễn';
    }
  }

  String get description {
    switch (this) {
      case MicrophonePermissionState.unknown:
        return 'Cần bật quyền microphone để sử dụng tính năng phát hiện âm thanh';
      case MicrophonePermissionState.granted:
        return 'Đã có quyền ghi âm';
      case MicrophonePermissionState.denied:
        return 'Quyền microphone bị từ chối. Bạn có thể bật lại trong cài đặt.';
      case MicrophonePermissionState.permanentlyDenied:
        return 'Quyền microphone bị từ chối vĩnh viễn. Vui lòng bật trong Cài đặt > Quyền riêng tư.';
    }
  }
}
