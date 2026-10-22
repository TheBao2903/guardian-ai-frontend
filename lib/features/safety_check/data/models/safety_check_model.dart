/// ============================================================================
/// FILE: lib/features/safety_check/data/models/safety_check_model.dart
/// MODULE: Safety Check - Data Models
/// ROLE:
///   DTO Serialization và Deserialization cho Safety Check Instance.
/// ============================================================================

import '../../domain/entities/safety_check_entity.dart';

class SafetyCheckModel {
  const SafetyCheckModel({
    required this.instanceId,
    required this.name,
    this.templateId,
    required this.status,
    required this.durationMinutes,
    required this.gracePeriodSeconds,
    this.startedAt,
    this.expiresAt,
    this.gracePeriodUntil,
    this.extensionCount = 0,
    this.maxExtensions = 3,
    this.notes,
  });

  final String instanceId;
  final String name;
  final String? templateId;
  final String status;
  final int durationMinutes;
  final int gracePeriodSeconds;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final DateTime? gracePeriodUntil;
  final int extensionCount;
  final int maxExtensions;
  final String? notes;

  factory SafetyCheckModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return SafetyCheckModel(
      instanceId: json['instance_id'] as String,
      name: json['name'] as String,
      templateId: json['template_id'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      gracePeriodSeconds: (json['grace_period_seconds'] as num?)?.toInt() ?? 60,
      startedAt: parseDateTime(json['started_at']),
      expiresAt: parseDateTime(json['expires_at']),
      gracePeriodUntil: parseDateTime(json['grace_period_until']),
      extensionCount: (json['extension_count'] as num?)?.toInt() ?? 0,
      maxExtensions: (json['max_extensions'] as num?)?.toInt() ?? 3,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instance_id': instanceId,
      'name': name,
      'template_id': templateId,
      'status': status,
      'duration_minutes': durationMinutes,
      'grace_period_seconds': gracePeriodSeconds,
      'started_at': startedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'grace_period_until': gracePeriodUntil?.toIso8601String(),
      'extension_count': extensionCount,
      'max_extensions': maxExtensions,
      'notes': notes,
    };
  }

  SafetyCheckEntity toEntity() {
    SafetyCheckStatus mappedStatus;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        mappedStatus = SafetyCheckStatus.active;
        break;
      case 'CHECK_REQUIRED':
        mappedStatus = SafetyCheckStatus.checkRequired;
        break;
      case 'COMPLETED':
        mappedStatus = SafetyCheckStatus.completed;
        break;
      case 'CANCELLED':
      case 'CANCELED':
        mappedStatus = SafetyCheckStatus.cancelled;
        break;
      case 'ESCALATED':
        mappedStatus = SafetyCheckStatus.escalated;
        break;
      default:
        mappedStatus = SafetyCheckStatus.active;
    }

    return SafetyCheckEntity(
      instanceId: instanceId,
      name: name,
      templateId: templateId,
      status: mappedStatus,
      durationMinutes: durationMinutes,
      gracePeriodSeconds: gracePeriodSeconds,
      startedAt: startedAt,
      expiresAt: expiresAt,
      gracePeriodUntil: gracePeriodUntil,
      extensionCount: extensionCount,
      maxExtensions: maxExtensions,
      notes: notes,
    );
  }
}
