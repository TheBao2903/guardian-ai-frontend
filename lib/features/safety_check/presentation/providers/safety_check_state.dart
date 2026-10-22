/// ============================================================================
/// FILE: lib/features/safety_check/presentation/providers/safety_check_state.dart
/// MODULE: Safety Check - Presentation State
/// ROLE:
///   Quản lý toàn bộ UI State của tính năng Safety Check Timer.
///   Hỗ trợ 5 mốc cố định + 1 mốc tùy chỉnh cho mỗi template.
/// ============================================================================

import '../../domain/entities/safety_check_entity.dart';
import '../../domain/entities/safety_check_template_entity.dart';

class SafetyCheckState {
  const SafetyCheckState({
    this.isLoading = false,
    this.errorMessage,
    this.templates = const [],
    this.selectedTemplate,
    this.selectedDurationMinutes = 20,
    this.customDurationMinutes,
    this.isCustomDurationSelected = false,
    this.activeInstance,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.isInGracePeriod = false,
    this.graceRemainingSeconds = 0,
    this.isActionLoading = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<SafetyCheckTemplateEntity> templates;
  final SafetyCheckTemplateEntity? selectedTemplate;

  /// Số phút được chọn để đếm ngược (từ 5 mốc cố định hoặc tùy chỉnh)
  final int selectedDurationMinutes;
  final int? customDurationMinutes;
  final bool isCustomDurationSelected;

  /// Phiên đếm ngược đang chạy
  final SafetyCheckEntity? activeInstance;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isInGracePeriod;
  final int graceRemainingSeconds;
  final bool isActionLoading;

  bool get hasActiveCheck =>
      activeInstance != null &&
      (activeInstance!.isActive || activeInstance!.isCheckRequired);

  double get progressRatio {
    if (totalSeconds <= 0) return 0.0;
    return (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  SafetyCheckState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SafetyCheckTemplateEntity>? templates,
    SafetyCheckTemplateEntity? selectedTemplate,
    int? selectedDurationMinutes,
    int? customDurationMinutes,
    bool? isCustomDurationSelected,
    SafetyCheckEntity? activeInstance,
    int? remainingSeconds,
    int? totalSeconds,
    bool? isInGracePeriod,
    int? graceRemainingSeconds,
    bool? isActionLoading,
    bool clearActiveInstance = false,
    bool clearSelectedTemplate = false,
  }) {
    return SafetyCheckState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      templates: templates ?? this.templates,
      selectedTemplate: clearSelectedTemplate
          ? null
          : (selectedTemplate ?? this.selectedTemplate),
      selectedDurationMinutes:
          selectedDurationMinutes ?? this.selectedDurationMinutes,
      customDurationMinutes:
          customDurationMinutes ?? this.customDurationMinutes,
      isCustomDurationSelected:
          isCustomDurationSelected ?? this.isCustomDurationSelected,
      activeInstance:
          clearActiveInstance ? null : (activeInstance ?? this.activeInstance),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isInGracePeriod: isInGracePeriod ?? this.isInGracePeriod,
      graceRemainingSeconds:
          graceRemainingSeconds ?? this.graceRemainingSeconds,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }
}
