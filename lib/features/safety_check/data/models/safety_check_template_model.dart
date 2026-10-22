/// ============================================================================
/// FILE: lib/features/safety_check/data/models/safety_check_template_model.dart
/// MODULE: Safety Check - Data Models
/// ROLE:
///   DTO Serialization và Deserialization cho Safety Check Template.
/// ============================================================================

import '../../domain/entities/safety_check_template_entity.dart';

class SafetyCheckTemplateModel {
  const SafetyCheckTemplateModel({
    required this.templateId,
    required this.name,
    this.description,
    required this.defaultDurationMinutes,
    this.defaultGracePeriodSeconds = 60,
    this.icon,
    this.isSystem = true,
    this.presetDurations,
  });

  final String templateId;
  final String name;
  final String? description;
  final int defaultDurationMinutes;
  final int defaultGracePeriodSeconds;
  final String? icon;
  final bool isSystem;
  final List<int>? presetDurations;

  factory SafetyCheckTemplateModel.fromJson(Map<String, dynamic> json) {
    return SafetyCheckTemplateModel(
      templateId: json['template_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      defaultDurationMinutes: (json['default_duration_minutes'] as num).toInt(),
      defaultGracePeriodSeconds:
          (json['default_grace_period_seconds'] as num?)?.toInt() ?? 60,
      icon: json['icon'] as String?,
      isSystem: json['is_system'] as bool? ?? true,
      presetDurations: (json['preset_durations'] as List?)
          ?.map((value) => (value as num).toInt())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'name': name,
      'description': description,
      'default_duration_minutes': defaultDurationMinutes,
      'default_grace_period_seconds': defaultGracePeriodSeconds,
      'icon': icon,
      'is_system': isSystem,
      'preset_durations': presetDurations,
    };
  }

  /// Chuyển đổi sang Domain Entity kèm 5 mốc thời gian cố định theo từng loại hoạt động
  SafetyCheckTemplateEntity toEntity() {
    List<int> presets;
    switch (templateId) {
      case 'tpl_walk_home':
        presets = [10, 15, 20, 30, 45];
        break;
      case 'tpl_late_ride':
        presets = [15, 25, 30, 45, 60];
        break;
      case 'tpl_exercise':
        presets = [20, 30, 45, 60, 90];
        break;
      case 'tpl_meetup':
        presets = [30, 45, 60, 90, 120];
        break;
      case 'tpl_overtime':
        presets = [60, 90, 120, 180, 240];
        break;
      default:
        // Với template tùy chỉnh, tính toán 5 mốc xoay quanh defaultDurationMinutes
        final base = defaultDurationMinutes;
        presets = [
          (base * 0.5).round().clamp(5, 1440),
          (base * 0.75).round().clamp(10, 1440),
          base,
          (base * 1.5).round().clamp(15, 1440),
          (base * 2.0).round().clamp(20, 1440),
        ];
    }

    return SafetyCheckTemplateEntity(
      id: templateId,
      name: name,
      description: description ?? '',
      defaultDurationMinutes: defaultDurationMinutes,
      defaultGracePeriodSeconds: defaultGracePeriodSeconds,
      icon: icon ?? 'shield',
      presetDurations: presetDurations ?? presets,
      isSystem: isSystem,
    );
  }
}
