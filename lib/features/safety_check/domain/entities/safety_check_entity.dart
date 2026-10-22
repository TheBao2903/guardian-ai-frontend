/// ============================================================================
/// FILE: lib/features/safety_check/domain/entities/safety_check_entity.dart
/// MODULE: Safety Check - Domain Entities
/// ROLE:
///   Định nghĩa thực thể phiên hẹn giờ an toàn đang hoạt động (Active Instance).
/// ============================================================================

enum SafetyCheckStatus {
  active,
  checkRequired,
  completed,
  cancelled,
  escalated,
}

class SafetyCheckEntity {
  const SafetyCheckEntity({
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
  final SafetyCheckStatus status;
  final int durationMinutes;
  final int gracePeriodSeconds;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final DateTime? gracePeriodUntil;
  final int extensionCount;
  final int maxExtensions;
  final String? notes;

  bool get isActive => status == SafetyCheckStatus.active;
  bool get isCheckRequired => status == SafetyCheckStatus.checkRequired;
  bool get isEscalated => status == SafetyCheckStatus.escalated;
  bool get isCompleted => status == SafetyCheckStatus.completed;
  bool get isCancelled => status == SafetyCheckStatus.cancelled;

  bool get canExtend =>
      extensionCount < maxExtensions && (isActive || isCheckRequired);

  SafetyCheckEntity copyWith({
    String? instanceId,
    String? name,
    String? templateId,
    SafetyCheckStatus? status,
    int? durationMinutes,
    int? gracePeriodSeconds,
    DateTime? startedAt,
    DateTime? expiresAt,
    DateTime? gracePeriodUntil,
    int? extensionCount,
    int? maxExtensions,
    String? notes,
  }) {
    return SafetyCheckEntity(
      instanceId: instanceId ?? this.instanceId,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      gracePeriodSeconds: gracePeriodSeconds ?? this.gracePeriodSeconds,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      gracePeriodUntil: gracePeriodUntil ?? this.gracePeriodUntil,
      extensionCount: extensionCount ?? this.extensionCount,
      maxExtensions: maxExtensions ?? this.maxExtensions,
      notes: notes ?? this.notes,
    );
  }
}
