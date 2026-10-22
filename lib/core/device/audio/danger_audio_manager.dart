/// Danger Audio Manager - Models and Types
library;

import 'recording/microphone_permission_service.dart';

/// Event types for danger detection
enum DangerEventType {
  scream,
  distressCry,
  gunshot,
  glassBreak,
  alarm,
  unknown,
}

/// Configuration for danger audio detection
class DangerAudioConfig {
  /// Minimum confidence threshold (0.0 - 1.0)
  final double minConfidence;

  /// Minimum amplitude in dB (typically -160 to 0)
  final double minAmplitude;

  /// Cooldown per event type in seconds
  final Map<DangerEventType, int> cooldowns;

  /// Max clips per session
  final int maxClipsPerSession;

  /// Max pending uploads
  final int maxPendingUploads;

  /// API endpoint for upload
  final String? uploadEndpoint;

  /// Auth token for API
  final String? authToken;

  const DangerAudioConfig({
    this.minConfidence = 0.7,
    this.minAmplitude = -40.0,
    this.cooldowns = const {
      DangerEventType.scream: 30,
      DangerEventType.distressCry: 15,
      DangerEventType.gunshot: 60,
      DangerEventType.glassBreak: 30,
      DangerEventType.alarm: 30,
    },
    this.maxClipsPerSession = 3,
    this.maxPendingUploads = 2,
    this.uploadEndpoint,
    this.authToken,
  });
}

/// Detection result with event type
class DangerDetectionResult {
  final bool detected;
  final DangerEventType? eventType;
  final double confidence;
  final DateTime timestamp;
  final double amplitude;

  const DangerDetectionResult({
    required this.detected,
    this.eventType,
    required this.confidence,
    required this.timestamp,
    required this.amplitude,
  });

  factory DangerDetectionResult.none() => DangerDetectionResult(
        detected: false,
        confidence: 0.0,
        timestamp: DateTime.now(),
        amplitude: 0.0,
      );

  String get eventTypeName {
    switch (eventType) {
      case DangerEventType.scream:
        return 'SCREAM';
      case DangerEventType.distressCry:
        return 'DISTRESS_CRY';
      case DangerEventType.gunshot:
        return 'GUNSHOT';
      case DangerEventType.glassBreak:
        return 'GLASS_BREAK';
      case DangerEventType.alarm:
        return 'ALARM';
      case null:
      case DangerEventType.unknown:
        return 'UNKNOWN';
    }
  }

  String get displayName {
    switch (eventType) {
      case DangerEventType.scream:
        return 'Tiếng hét';
      case DangerEventType.distressCry:
        return 'Tiếng khóc cầu cứu';
      case DangerEventType.gunshot:
        return 'Tiếng súng';
      case DangerEventType.glassBreak:
        return 'Kính vỡ';
      case DangerEventType.alarm:
        return 'Báo động';
      case null:
      case DangerEventType.unknown:
        return 'Không xác định';
    }
  }
}

/// State for danger audio manager
class DangerAudioState {
  final String? deliveryStatus;
  final int recipientsTotal, recipientsSent, recipientsFailed;
  final bool isEnabled;
  final bool isMonitoring;
  final bool hasPermission;
  final MicrophonePermissionState permissionState;
  final DangerDetectionResult? lastDetection;
  final List<DangerDetectionResult> detectionHistory;
  final int pendingUploads;
  final int completedUploads;
  final int failedUploads;
  final String? error;
  final Map<String, int> cooldowns;

  const DangerAudioState({
    this.deliveryStatus,
    this.recipientsTotal = 0,
    this.recipientsSent = 0,
    this.recipientsFailed = 0,
    this.isEnabled = false,
    this.isMonitoring = false,
    this.hasPermission = false,
    this.permissionState = MicrophonePermissionState.unknown,
    this.lastDetection,
    this.detectionHistory = const [],
    this.pendingUploads = 0,
    this.completedUploads = 0,
    this.failedUploads = 0,
    this.error,
    this.cooldowns = const {},
  });

  DangerAudioState copyWith({
    String? deliveryStatus,
    int? recipientsTotal,
    int? recipientsSent,
    int? recipientsFailed,
    bool? isEnabled,
    bool? isMonitoring,
    bool? hasPermission,
    MicrophonePermissionState? permissionState,
    DangerDetectionResult? lastDetection,
    List<DangerDetectionResult>? detectionHistory,
    int? pendingUploads,
    int? completedUploads,
    int? failedUploads,
    String? error,
    Map<String, int>? cooldowns,
  }) {
    return DangerAudioState(
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      recipientsTotal: recipientsTotal ?? this.recipientsTotal,
      recipientsSent: recipientsSent ?? this.recipientsSent,
      recipientsFailed: recipientsFailed ?? this.recipientsFailed,
      isEnabled: isEnabled ?? this.isEnabled,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      hasPermission: hasPermission ?? this.hasPermission,
      permissionState: permissionState ?? this.permissionState,
      lastDetection: lastDetection ?? this.lastDetection,
      detectionHistory: detectionHistory ?? this.detectionHistory,
      pendingUploads: pendingUploads ?? this.pendingUploads,
      completedUploads: completedUploads ?? this.completedUploads,
      failedUploads: failedUploads ?? this.failedUploads,
      error: error,
      cooldowns: cooldowns ?? this.cooldowns,
    );
  }
}
