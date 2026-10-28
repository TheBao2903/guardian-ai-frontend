/// ============================================================================
/// FILE: lib/features/safety_check/presentation/providers/safety_check_controller.dart
/// MODULE: Safety Check - Presentation Controller
/// ROLE:
///   StateNotifier điều phối toàn bộ luồng Hẹn giờ an toàn,
///   đồng bộ Timer chạy từng giây, xử lý Grace Period và chuyển tiếp SOS.
/// ============================================================================

library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/device/flashlight/flashlight_controller.dart';
import '../../../../core/device/audio/danger_audio_providers.dart';
import '../../../../core/device/location/location_service.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/safety_check_entity.dart';
import '../../domain/entities/safety_check_template_entity.dart';
import '../../data/repositories/safety_check_repository_impl.dart';
import '../../domain/usecases/safety_check_usecases_providers.dart';
import '../../../sos/presentation/providers/sos_controller.dart';
import '../../../sos/presentation/providers/sos_state.dart';
import 'safety_check_state.dart';

final safetyCheckClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

final safetyCheckControllerProvider =
    StateNotifierProvider<SafetyCheckController, SafetyCheckState>((ref) {
  return SafetyCheckController(ref);
});

class SafetyCheckController extends StateNotifier<SafetyCheckState> {
  SafetyCheckController(this._ref) : super(const SafetyCheckState()) {
    init();
    _ref.listen<SosState>(sosControllerProvider, (previous, next) {
      if (next.isSosActive && state.hasActiveCheck) {
        _ticker?.cancel();
        state = state.copyWith(
          activeInstance: state.activeInstance
              ?.copyWith(status: SafetyCheckStatus.escalated),
        );
      }
    });
  }

  final Ref _ref;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Khởi tạo dữ liệu ban đầu
  Future<void> init() async {
    final token =
        await _ref.read(secureStorageProvider).read(StorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      state = state.copyWith(
        templates: SafetyCheckTemplateEntity.systemTemplates,
        selectedTemplate: SafetyCheckTemplateEntity.systemTemplates.first,
        selectedDurationMinutes: SafetyCheckTemplateEntity
            .systemTemplates.first.defaultDurationMinutes,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    // 1. Tải danh sách templates
    final getTemplatesUseCase =
        _ref.read(getSafetyCheckTemplatesUseCaseProvider);
    final templatesResult = await getTemplatesUseCase();

    List<SafetyCheckTemplateEntity> templates = [];
    String? templatesError;
    templatesResult.when(
      success: (data) => templates = data,
      error: (failure) => templatesError = failure.message,
    );

    final initialTemplate = templates.isNotEmpty ? templates.first : null;
    final initialDuration = initialTemplate?.defaultDurationMinutes ?? 20;

    state = state.copyWith(
      isLoading: false,
      templates: templates,
      selectedTemplate: initialTemplate,
      clearSelectedTemplate: initialTemplate == null,
      errorMessage: templatesError,
      selectedDurationMinutes: initialDuration,
      isCustomDurationSelected: false,
    );

    // 2. Kiểm tra xem có phiên nào đang chạy dở trên server không
    await _checkCurrentActiveSession();
  }

  Future<void> _checkCurrentActiveSession() async {
    final getCurrentUseCase = _ref.read(getCurrentSafetyCheckUseCaseProvider);
    final result = await getCurrentUseCase();

    result.when(
      success: (active) {
        if (active != null && (active.isActive || active.isCheckRequired)) {
          _resumeActiveSession(active);
          unawaited(_ref
              .read(dangerAudioProvider.notifier)
              .startMonitoring(safetyCheckInstanceId: active.instanceId));
        }
      },
      error: (_) {
        // Bỏ qua nếu lỗi mạng
      },
    );
  }

  /// Khôi phục đếm ngược cho phiên đang active
  void _resumeActiveSession(SafetyCheckEntity active) {
    final now = _ref.read(safetyCheckClockProvider)();
    final startedAt = active.startedAt ?? now;
    final expiresAt = active.expiresAt ??
        startedAt.add(Duration(minutes: active.durationMinutes));
    state = state.copyWith(
      activeInstance: active.copyWith(
          startedAt: startedAt,
          expiresAt: expiresAt,
          gracePeriodUntil: active.gracePeriodUntil ??
              expiresAt.add(Duration(seconds: active.gracePeriodSeconds))),
      totalSeconds: expiresAt.difference(startedAt).inSeconds,
      isActionLoading: false,
    );
    _startLocalTicker();
  }

  /// Chọn template
  Future<bool> saveTemplate(Map<String, dynamic> data,
      {String? templateId}) async {
    if (state.hasActiveCheck || state.isActionLoading) return false;
    state = state.copyWith(isActionLoading: true);
    final result = await _ref
        .read(safetyCheckRepositoryProvider)
        .saveTemplate(data, templateId: templateId);
    if (!mounted) return false;
    return result.when(success: (saved) {
      final templates = [...state.templates];
      final index = templates.indexWhere((item) => item.id == saved.id);
      if (index < 0) {
        templates.add(saved);
      } else {
        templates[index] = saved;
      }
      state = state.copyWith(templates: templates, isActionLoading: false);
      selectTemplate(saved);
      return true;
    }, error: (failure) {
      state =
          state.copyWith(isActionLoading: false, errorMessage: failure.message);
      return false;
    });
  }

  Future<bool> deleteTemplate(String id) async {
    if (state.hasActiveCheck || state.isActionLoading) return false;
    state = state.copyWith(isActionLoading: true);
    final result =
        await _ref.read(safetyCheckRepositoryProvider).deleteTemplate(id);
    if (!mounted) return false;
    return result.when(success: (_) {
      final templates = state.templates.where((item) => item.id != id).toList();
      final deletedSelection = state.selectedTemplate?.id == id;
      state = state.copyWith(
          templates: templates,
          isActionLoading: false,
          clearSelectedTemplate: deletedSelection);
      if (deletedSelection && templates.isNotEmpty) {
        selectTemplate(templates.first);
      }
      return true;
    }, error: (failure) {
      state =
          state.copyWith(isActionLoading: false, errorMessage: failure.message);
      return false;
    });
  }

  void selectTemplate(SafetyCheckTemplateEntity template) {
    if (state.hasActiveCheck) return;
    state = state.copyWith(
      selectedTemplate: template,
      selectedDurationMinutes: template.defaultDurationMinutes,
      isCustomDurationSelected:
          !template.presetDurations.contains(template.defaultDurationMinutes),
    );
  }

  /// Chọn 1 trong 5 mốc thời gian cố định
  void selectPresetDuration(int minutes) {
    if (state.hasActiveCheck) return;
    state = state.copyWith(
      selectedDurationMinutes: minutes,
      isCustomDurationSelected: false,
    );
  }

  /// Chọn mốc thời gian tùy chỉnh
  void setCustomDuration(int minutes) {
    if (state.hasActiveCheck) return;
    final clamped = minutes.clamp(1, 1440);
    state = state.copyWith(
      selectedDurationMinutes: clamped,
      customDurationMinutes: clamped,
      isCustomDurationSelected: true,
    );
  }

  /// Bắt đầu phiên hẹn giờ an toàn
  Future<bool> startSafetyCheck({String? customNotes}) async {
    if (state.hasActiveCheck ||
        state.isActionLoading ||
        state.selectedTemplate == null) {
      return false;
    }

    state = state.copyWith(isActionLoading: true);

    // Lấy tọa độ GPS hiện tại nếu có quyền
    final locationService = _ref.read(locationServiceProvider);
    final pos = await locationService.getCurrentLocation();

    final startUseCase = _ref.read(startSafetyCheckUseCaseProvider);
    final template = state.selectedTemplate;
    final durationMinutes = state.selectedDurationMinutes;

    final result = await startUseCase(
      templateId: template?.id,
      customName: template?.name ?? 'Kiểm tra an toàn',
      durationMinutes: durationMinutes,
      gracePeriodSeconds: template?.defaultGracePeriodSeconds ?? 60,
      latitude: pos?.latitude,
      longitude: pos?.longitude,
      notes: customNotes,
    );

    return result.when(
      success: (instance) async {
        _resumeActiveSession(instance);

        // Kích hoạt Audio Shield để lắng nghe tiếng hét
        await _ref
            .read(dangerAudioProvider.notifier)
            .startMonitoring(safetyCheckInstanceId: instance.instanceId);

        // Starting a timer must not open the camera or trigger another prompt.
        unawaited(_ref.read(flashlightControllerProvider).refreshPermission());

        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Recompute from server deadlines; browser timer throttling must not extend
  /// either the check or its grace period.
  void _startLocalTicker() {
    _ticker?.cancel();
    _ticker =
        Timer.periodic(const Duration(seconds: 1), (_) => _refreshCountdown());
    _refreshCountdown();
  }

  void _refreshCountdown() {
    final active = state.activeInstance;
    if (active == null || active.expiresAt == null) return;
    final now = _ref.read(safetyCheckClockProvider)();
    int secondsUntil(DateTime deadline) =>
        (deadline.difference(now).inMilliseconds / 1000)
            .ceil()
            .clamp(0, 2147483647);
    final remaining = secondsUntil(active.expiresAt!);
    final graceDeadline = active.gracePeriodUntil ??
        active.expiresAt!.add(Duration(seconds: active.gracePeriodSeconds));
    final grace =
        remaining > 0 ? active.gracePeriodSeconds : secondsUntil(graceDeadline);
    final expired = remaining == 0 && grace == 0;
    state = state.copyWith(
      remainingSeconds: remaining,
      isInGracePeriod: remaining == 0 && !expired,
      graceRemainingSeconds: grace,
      activeInstance: expired
          ? active.copyWith(status: SafetyCheckStatus.escalated)
          : active,
    );
    if (expired) {
      _ticker?.cancel();
      unawaited(_ref.read(sosControllerProvider.notifier).activateSos(triggerType: 'SAFETY_CHECK_ESCALATED'));
    }
  }

  /// Người dùng bấm 'Tôi an toàn'
  Future<bool> confirmSafe({String? note}) async {
    final active = state.activeInstance;
    if (active == null) return false;

    state = state.copyWith(isActionLoading: true);
    final confirmUseCase = _ref.read(confirmSafeUseCaseProvider);
    final result = await confirmUseCase(
      instanceId: active.instanceId,
      note: note,
    );

    return result.when(
      success: (_) {
        _ticker?.cancel();
        // Dừng Audio Shield khi user báo an toàn
        _ref.read(dangerAudioProvider.notifier).stopMonitoring();
        unawaited(_ref.read(flashlightControllerProvider).turnOff());
        state = state.copyWith(
          isActionLoading: false,
          clearActiveInstance: true,
          remainingSeconds: 0,
          isInGracePeriod: false,
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Gia hạn thêm thời gian (+15 phút)
  Future<bool> extendTimer({int extendMinutes = 15}) async {
    final active = state.activeInstance;
    if (active == null || !active.canExtend) return false;

    state = state.copyWith(isActionLoading: true);
    final extendUseCase = _ref.read(extendSafetyCheckUseCaseProvider);
    final result = await extendUseCase(
      instanceId: active.instanceId,
      extendMinutes: extendMinutes,
    );

    return result.when(
      success: (updatedInstance) {
        _resumeActiveSession(updatedInstance);
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Hủy phiên hẹn giờ
  Future<bool> cancelTimer({String? reason}) async {
    final active = state.activeInstance;
    if (active == null) return false;

    state = state.copyWith(isActionLoading: true);
    final cancelUseCase = _ref.read(cancelSafetyCheckUseCaseProvider);
    final result = await cancelUseCase(
      instanceId: active.instanceId,
      reason: reason,
    );

    return result.when(
      success: (_) {
        _ticker?.cancel();
        // Dừng Audio Shield khi hủy timer
        _ref.read(dangerAudioProvider.notifier).stopMonitoring();
        unawaited(_ref.read(flashlightControllerProvider).turnOff());
        state = state.copyWith(
          isActionLoading: false,
          clearActiveInstance: true,
          remainingSeconds: 0,
          isInGracePeriod: false,
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }
}
