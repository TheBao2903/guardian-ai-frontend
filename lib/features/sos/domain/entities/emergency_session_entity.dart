/// ============================================================================
/// FILE: lib/features/sos/domain/entities/emergency_session_entity.dart
/// MODULE: Emergency & SOS - Domain Entities
/// ROLE:
///   Đại diện cho phiên khẩn cấp SOS đang hoạt động trong hệ thống.
/// ============================================================================

enum EmergencyStatusEnum {
  created,
  active,
  resolved,
  cancelled,
  expired,
}

class EmergencySessionEntity {
  const EmergencySessionEntity({
    required this.sessionId,
    required this.userId,
    required this.status,
    required this.triggerType,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.mapsUrl,
    this.notes,
    this.activatedAt,
  });

  final String sessionId;
  final String userId;
  final EmergencyStatusEnum status;
  final String triggerType;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final String? mapsUrl;
  final String? notes;
  final DateTime? activatedAt;

  String get id => sessionId;
  bool get isActive => status == EmergencyStatusEnum.active;
  bool get isCancelled => status == EmergencyStatusEnum.cancelled;
  bool get isResolved => status == EmergencyStatusEnum.resolved;

  EmergencySessionEntity copyWith({
    String? sessionId,
    String? userId,
    EmergencyStatusEnum? status,
    String? triggerType,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? mapsUrl,
    String? notes,
    DateTime? activatedAt,
  }) {
    return EmergencySessionEntity(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      triggerType: triggerType ?? this.triggerType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      notes: notes ?? this.notes,
      activatedAt: activatedAt ?? this.activatedAt,
    );
  }
}
