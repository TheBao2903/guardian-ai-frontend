/// ============================================================================
/// FILE: lib/features/sos/presentation/providers/sos_state.dart
/// MODULE: Emergency & SOS - Presentation State
/// ============================================================================

library;

import '../../../contacts/domain/entities/contact_entity.dart';
import '../../domain/entities/emergency_session_entity.dart';

class SosState {
  const SosState({
    this.isLoading = false,
    this.errorMessage,
    this.activeSession,
    this.currentLatitude,
    this.currentLongitude,
    this.currentAccuracy,
    this.isSirenPlaying = false,
    this.isStrobeActive = false,
    this.isAudioRecording = false,
    this.pinCode = '1234', // Mã PIN 4 số cố định an toàn mặc định
    this.duressPinCode =
        '9999', // Mã PIN cưỡng bức (Duress PIN) đánh lừa kẻ cướp
    this.hasChangedPin =
        false, // Đánh dấu user đã từng đổi PIN (true = không còn fallback '1234')
    this.hasChangedDuressPin =
        false, // Đánh dấu user đã từng đổi Duress PIN (true = không còn fallback '9999')
    this.priorityContacts = const [], // Danh sách 5 người thân ưu tiên
    this.audioUploadStatus, // Trạng thái upload audio
    this.activeRecordingId, // ID của recording đang upload
    this.isPendingActivation =
        false, // Đang trong quá trình kích hoạt SOS (trước khi API backend phản hồi)
  });

  final bool isLoading;
  final bool isPendingActivation;
  final String? errorMessage;
  final EmergencySessionEntity? activeSession;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? currentAccuracy;
  final bool isSirenPlaying;
  final bool isStrobeActive;
  final bool isAudioRecording;
  final String pinCode;
  final String duressPinCode;
  final bool hasChangedPin;
  final bool hasChangedDuressPin;
  final List<ContactEntity> priorityContacts;
  final AudioUploadStatus? audioUploadStatus;
  final String? activeRecordingId;

  bool get isSosActive => (activeSession != null && activeSession!.isActive);

  /// Lấy người liên hệ ưu tiên #1
  ContactEntity? get primaryContact =>
      priorityContacts.isNotEmpty ? priorityContacts.first : null;

  /// Lấy 4 người liên hệ tiếp theo (priority 2-5)
  List<ContactEntity> get secondaryContacts =>
      priorityContacts.length > 1 ? priorityContacts.sublist(1) : [];

  SosState copyWith({
    bool? isLoading,
    bool? isPendingActivation,
    String? errorMessage,
    EmergencySessionEntity? activeSession,
    double? currentLatitude,
    double? currentLongitude,
    double? currentAccuracy,
    bool? isSirenPlaying,
    bool? isStrobeActive,
    bool? isAudioRecording,
    String? pinCode,
    String? duressPinCode,
    bool? hasChangedPin,
    bool? hasChangedDuressPin,
    List<ContactEntity>? priorityContacts,
    AudioUploadStatus? audioUploadStatus,
    String? activeRecordingId,
    bool clearActiveSession = false,
    bool clearAudioStatus = false,
  }) {
    return SosState(
      isLoading: isLoading ?? this.isLoading,
      isPendingActivation: isPendingActivation ??
          (clearActiveSession ? false : this.isPendingActivation),
      errorMessage: errorMessage,
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      currentAccuracy: currentAccuracy ?? this.currentAccuracy,
      isSirenPlaying: isSirenPlaying ?? this.isSirenPlaying,
      isStrobeActive: isStrobeActive ?? this.isStrobeActive,
      isAudioRecording: isAudioRecording ?? this.isAudioRecording,
      pinCode: pinCode ?? this.pinCode,
      duressPinCode: duressPinCode ?? this.duressPinCode,
      hasChangedPin: hasChangedPin ?? this.hasChangedPin,
      hasChangedDuressPin: hasChangedDuressPin ?? this.hasChangedDuressPin,
      priorityContacts: priorityContacts ?? this.priorityContacts,
      audioUploadStatus: clearAudioStatus
          ? null
          : (audioUploadStatus ?? this.audioUploadStatus),
      activeRecordingId: activeRecordingId ?? this.activeRecordingId,
    );
  }
}

/// Trạng thái upload audio evidence
class AudioUploadStatus {
  final String state; // 'pending', 'uploading', 'uploaded', 'failed'
  final double? progress;
  final String? error;

  const AudioUploadStatus({
    required this.state,
    this.progress,
    this.error,
  });

  bool get isUploading => state == 'uploading';
  bool get isUploaded => state == 'uploaded';
  bool get isFailed => state == 'failed';
  bool get isPending => state == 'pending';
}
