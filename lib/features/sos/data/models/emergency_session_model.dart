/// ============================================================================
/// FILE: lib/features/sos/data/models/emergency_session_model.dart
/// MODULE: Emergency & SOS - Data Models
/// ROLE:
///   DTO Serialization và Deserialization cho EmergencySession.
/// ============================================================================

import '../../domain/entities/emergency_session_entity.dart';

class EmergencySessionModel {
  const EmergencySessionModel({
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
  final String status;
  final String triggerType;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final String? mapsUrl;
  final String? notes;
  final DateTime? activatedAt;

  factory EmergencySessionModel.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;
    double? acc;

    final loc = json['latest_location'] ?? json['initial_location'];
    if (loc is Map<String, dynamic>) {
      lat = (loc['latitude'] as num?)?.toDouble();
      lng = (loc['longitude'] as num?)?.toDouble();
      acc = (loc['accuracy_meters'] as num?)?.toDouble();
    }

    DateTime? parseDateTime(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return EmergencySessionModel(
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String? ?? 'ACTIVE',
      triggerType: json['trigger_type'] as String? ?? 'MANUAL_SOS',
      latitude: lat,
      longitude: lng,
      accuracyMeters: acc,
      mapsUrl: json['maps_url'] as String?,
      notes: json['notes'] as String?,
      activatedAt: parseDateTime(json['activated_at']),
    );
  }

  EmergencySessionEntity toEntity() {
    EmergencyStatusEnum mappedStatus;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        mappedStatus = EmergencyStatusEnum.active;
        break;
      case 'RESOLVED':
        mappedStatus = EmergencyStatusEnum.resolved;
        break;
      case 'CANCELLED':
      case 'CANCELED':
        mappedStatus = EmergencyStatusEnum.cancelled;
        break;
      case 'EXPIRED':
        mappedStatus = EmergencyStatusEnum.expired;
        break;
      default:
        mappedStatus = EmergencyStatusEnum.active;
    }

    return EmergencySessionEntity(
      sessionId: sessionId,
      userId: userId,
      status: mappedStatus,
      triggerType: triggerType,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      mapsUrl: mapsUrl,
      notes: notes,
      activatedAt: activatedAt,
    );
  }
}
