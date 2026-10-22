/// ============================================================================
/// FILE: lib/features/safety_check/domain/entities/safety_check_template_entity.dart
/// MODULE: Safety Check - Domain Entities
/// ROLE:
///   Định nghĩa thực thể mẫu hẹn giờ an toàn (Template).
///   Theo quy định người dùng: Mỗi mẫu luôn có 5 mốc thời gian cố định
///   cộng thêm tùy chọn mốc tùy chỉnh (Custom Duration).
/// ============================================================================

class SafetyCheckTemplateEntity {
  const SafetyCheckTemplateEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultDurationMinutes,
    required this.defaultGracePeriodSeconds,
    required this.icon,
    required this.presetDurations,
    this.isSystem = true,
  });

  final String id;
  final String name;
  final String description;
  final int defaultDurationMinutes;
  final int defaultGracePeriodSeconds;
  final String icon;
  final List<int> presetDurations; // Đúng 5 mốc cố định
  final bool isSystem;

  /// Danh sách 5 mẫu mặc định sẵn sàng dùng kèm 5 mốc thời gian cố định tối ưu cho từng bối cảnh
  static const List<SafetyCheckTemplateEntity> systemTemplates = [
    SafetyCheckTemplateEntity(
      id: 'tpl_walk_home',
      name: 'Đi bộ về nhà',
      description: 'Bảo vệ khi đi bộ qua đoạn đường vắng hoặc trời tối.',
      defaultDurationMinutes: 20,
      defaultGracePeriodSeconds: 60,
      icon: 'footprints',
      presetDurations: [10, 15, 20, 30, 45],
    ),
    SafetyCheckTemplateEntity(
      id: 'tpl_late_ride',
      name: 'Đi xe / Taxi / Đặt xe',
      description: 'Theo dõi chuyến đi xe công nghệ, taxi ban đêm.',
      defaultDurationMinutes: 30,
      defaultGracePeriodSeconds: 60,
      icon: 'car',
      presetDurations: [15, 25, 30, 45, 60],
    ),
    SafetyCheckTemplateEntity(
      id: 'tpl_exercise',
      name: 'Chạy bộ / Thể thao',
      description: 'Theo dõi an toàn khi chạy bộ, tập thể dục ngoài trời.',
      defaultDurationMinutes: 45,
      defaultGracePeriodSeconds: 60,
      icon: 'activity',
      presetDurations: [20, 30, 45, 60, 90],
    ),
    SafetyCheckTemplateEntity(
      id: 'tpl_meetup',
      name: 'Gặp gỡ / Hẹn hò',
      description: 'Hẹn gặp đối tác, người mới quen hoặc nơi xa lạ.',
      defaultDurationMinutes: 60,
      defaultGracePeriodSeconds: 60,
      icon: 'users',
      presetDurations: [30, 45, 60, 90, 120],
    ),
    SafetyCheckTemplateEntity(
      id: 'tpl_overtime',
      name: 'Làm việc / Trực đêm',
      description: 'Làm việc tăng ca muộn tại văn phòng hoặc công tác.',
      defaultDurationMinutes: 120,
      defaultGracePeriodSeconds: 120,
      icon: 'moon',
      presetDurations: [60, 90, 120, 180, 240],
    ),
  ];
}
