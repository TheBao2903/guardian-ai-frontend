import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/audio/danger_audio_manager.dart';
import '../../../../core/device/audio/detection/server_audio_alert.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';

/// ============================================================================
/// FILE: danger_alert_sheet.dart
/// MODULE: Home - AI Danger Detection Alert Sheet
/// ROLE:
///   Hiển thị khi AI phát hiện tiếng hét/nguy hiểm:
///   - Đếm ngược 10 giây
///   - Tự động kích hoạt SOS nếu không hủy (qua callback onTimeoutTrigger)
///   - Cho phép hủy nếu là báo động giả
///   - Cho phép kích hoạt SOS ngay qua callback onConfirmed
///
///   Refactor: Bây giờ notifier nhận 2 callback từ caller
///   (danger_audio_providers) để tách biệt luồng phân tích audio và hành động SOS.
///   UI hiển thị qua `showGlobal()` thông qua rootNavigatorKey để popup
///   hiển thị trên mọi màn hình (kể cả Active SOS hoặc full-screen routes).
/// ============================================================================

/// Injected only for deterministic deadline tests; production uses wall time.
final dangerAlertClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

final dangerAlertProvider =
    StateNotifierProvider<DangerAlertNotifier, DangerAlertState>((ref) {
  return DangerAlertNotifier(ref);
});

class DangerAlertState {
  final String? alertId;
  final bool isCancelling;
  final bool isShowing;
  final DangerDetectionResult? detection;
  final int countdownSeconds;
  final bool sosTriggered;
  final bool isSubmitting;
  final String? error;
  final DateTime? deadline;

  const DangerAlertState({
    this.alertId,
    this.isCancelling = false,
    this.isShowing = false,
    this.detection,
    this.countdownSeconds = 10,
    this.sosTriggered = false,
    this.isSubmitting = false,
    this.error,
    this.deadline,
  });

  DangerAlertState copyWith({
    String? alertId,
    bool? isCancelling,
    bool? isShowing,
    DangerDetectionResult? detection,
    int? countdownSeconds,
    bool? sosTriggered,
    bool? isSubmitting,
    String? error,
    DateTime? deadline,
  }) =>
      DangerAlertState(
        alertId: alertId ?? this.alertId,
        isCancelling: isCancelling ?? this.isCancelling,
        isShowing: isShowing ?? this.isShowing,
        detection: detection ?? this.detection,
        countdownSeconds: countdownSeconds ?? this.countdownSeconds,
        sosTriggered: sosTriggered ?? this.sosTriggered,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
        deadline: deadline ?? this.deadline,
      );
}

class DangerAlertNotifier extends StateNotifier<DangerAlertState> {
  DangerAlertNotifier(Ref ref)
      : _now = ref.read(dangerAlertClockProvider),
        super(const DangerAlertState());

  final DateTime Function() _now;
  Timer? _countdownTimer;
  Future<void> Function()? _onTimeoutTrigger;
  Future<void> Function()? _onConfirmed;
  int _generation = 0;
  bool _serverManaged = false;
  Future<void> Function()? _onCancel;

  void synchronizeServerAlert(
    ServerAudioAlert alert, {
    required Future<void> Function() onConfirm,
    required Future<void> Function() onCancel,
  }) {
    final localDeadline =
        _now().add(alert.deadline.difference(alert.serverTime));
    final remaining =
        (alert.deadline.difference(alert.serverTime).inMilliseconds / 1000)
            .ceil()
            .clamp(0, 10);
    final same = state.alertId == alert.id;
    _serverManaged = true;
    _onConfirmed = onConfirm;
    _onCancel = onCancel;
    _onTimeoutTrigger = null;
    state = DangerAlertState(
        alertId: alert.id,
        isShowing: true,
        detection: same
            ? state.detection
            : DangerDetectionResult(
                detected: true,
                eventType: DangerEventType.scream,
                confidence: 0,
                timestamp: _now(),
                amplitude: 0),
        deadline: localDeadline,
        countdownSeconds: remaining,
        isSubmitting: same && state.isSubmitting,
        isCancelling: same && state.isCancelling,
        error: same ? state.error : null);
    if (!same) {
      _generation++;
      _startServerDisplayTimer();
    }
  }

  void _startServerDisplayTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final remaining =
          (state.deadline!.difference(_now()).inMilliseconds / 1000)
              .ceil()
              .clamp(0, 10);
      if (remaining != state.countdownSeconds) {
        state = state.copyWith(countdownSeconds: remaining, error: state.error);
      }
      // No client-side SOS call at zero. The durable worker owns dispatch.
    });
  }

  void resolveServerAlert(String id, {required bool sent}) {
    if (state.alertId != null && state.alertId != id) return;
    _generation++;
    _countdownTimer?.cancel();
    _onConfirmed = null;
    _onCancel = null;
    _onTimeoutTrigger = null;
    state = DangerAlertState(alertId: id, sosTriggered: sent);
  }

  void resetSession() {
    _generation++;
    _countdownTimer?.cancel();
    _onConfirmed = null;
    _onCancel = null;
    _onTimeoutTrigger = null;
    state = const DangerAlertState();
  }

  void showAlert(
    DangerDetectionResult detection, {
    Future<void> Function()? onTimeoutTrigger,
    Future<void> Function()? onConfirmed,
  }) {
    if (state.isShowing || state.isSubmitting) return;
    _serverManaged = false;
    _generation++;
    _onTimeoutTrigger = onTimeoutTrigger;
    _onConfirmed = onConfirmed;
    state = DangerAlertState(
      isShowing: true,
      detection: detection,
      deadline: _now().add(const Duration(seconds: 10)),
    );
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final milliseconds = state.deadline!.difference(_now()).inMilliseconds;
      if (milliseconds <= 0) {
        unawaited(_submit(_onTimeoutTrigger ?? _onConfirmed));
      } else {
        final remaining = (milliseconds / 1000).ceil();
        if (remaining != state.countdownSeconds) {
          state = state.copyWith(countdownSeconds: remaining);
        }
      }
    });
  }

  Future<void> dismissAlert() async {
    if (state.isSubmitting || state.isCancelling) return;
    if (!_serverManaged) {
      resetSession();
      return;
    }
    final generation = _generation;
    state = state.copyWith(isCancelling: true);
    try {
      if (_onCancel == null) throw StateError('Missing cancellation callback');
      await _onCancel!();
    } catch (_) {
      if (mounted && generation == _generation) {
        state = state.copyWith(
            isCancelling: false,
            error:
                'Chưa xác nhận hủy được. Cảnh báo vẫn có thể được gửi khi hết hạn.');
      }
    }
  }

  Future<void> confirmAlert() => _submit(_onConfirmed ?? _onTimeoutTrigger);

  Future<void> _submit(Future<void> Function()? callback) async {
    if (!state.isShowing ||
        state.isSubmitting ||
        state.isCancelling ||
        state.sosTriggered) {
      return;
    }
    final generation = _generation;
    _countdownTimer?.cancel();
    state = state.copyWith(isSubmitting: true, countdownSeconds: 0);
    try {
      if (callback == null) throw StateError('Chưa có kết nối gửi SOS.');
      await callback();
      if (!mounted || generation != _generation) return;
      if (_serverManaged) {
        state = state.copyWith(isSubmitting: false);
        return;
      }
      _onTimeoutTrigger = null;
      _onConfirmed = null;
      state = state.copyWith(
          isShowing: false, isSubmitting: false, sosTriggered: true);
    } catch (error) {
      if (!mounted || generation != _generation) return;
      state = state.copyWith(
          isSubmitting: false,
          error: 'Chưa gửi được SOS. Kiểm tra kết nối và bấm gửi lại.');
    }
  }

  @override
  void dispose() {
    _generation++;
    _countdownTimer?.cancel();
    super.dispose();
  }
}

/// ============================================================================
/// Widget: DangerAlertSheet
/// ============================================================================

class DangerAlertSheet extends ConsumerStatefulWidget {
  const DangerAlertSheet({super.key, this.closeOnDismiss = true});

  final bool closeOnDismiss;

  /// Hiện alert dưới dạng modal bottom sheet trong một context cụ thể
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      builder: (_) => const DangerAlertSheet(),
    );
  }

  /// Hiện alert thông qua rootNavigatorKey (hiển thị trên mọi màn hình).
  ///
  /// Sử dụng khi phát hiện từ background audio monitor — cần popup hiển thị
  /// kể cả khi user đang ở Active SOS Screen hoặc Login Screen.
  static Future<void> showGlobal(NavigatorState navigator) {
    return showModalBottomSheet<void>(
      context: navigator.context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      builder: (_) => const DangerAlertSheet(),
    );
  }

  @override
  ConsumerState<DangerAlertSheet> createState() => _DangerAlertSheetState();
}

class _DangerAlertSheetState extends ConsumerState<DangerAlertSheet> {
  /// Lắng nghe state.isShowing — tự động show/hide bottom sheet cho phù hợp
  ProviderSubscription<DangerAlertState>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ref.listenManual<DangerAlertState>(
      dangerAlertProvider,
      (prev, next) {
        // Khi isShowing chuyển từ false → true, đảm bảo sheet đang hiển thị
        // (Trong thực tế, sheet đã được show từ caller rồi, đây chỉ là safety)
        final wasShowing = prev?.isShowing ?? false;
        if (!wasShowing && next.isShowing) {
          // Sheet đã hiển thị bởi show() — không cần show lại
        }
        // Khi isShowing chuyển từ true → false, đóng sheet
        if (widget.closeOnDismiss && wasShowing && !next.isShowing) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final alertState = ref.watch(dangerAlertProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon cảnh báo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: colors.danger,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),

            // Tiêu đề
            Text(
              context.l10n.screamDetected,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Loại sự kiện
            if (alertState.detection != null &&
                alertState.detection!.confidence > 0)
              Text(
                context.l10n.sosDetectionType(
                    alertState.detection!.eventTypeName,
                    (alertState.detection!.confidence * 100)
                        .toStringAsFixed(0)),
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),

            // Đếm ngược
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_rounded, color: colors.danger, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    alertState.isCancelling
                        ? context.l10n.sosCancelling
                        : alertState.isSubmitting
                            ? context.l10n.sosSending
                            : alertState.error != null
                                ? context.l10n.sosSendFailed
                                : alertState.countdownSeconds == 0
                                    ? context.l10n.sosWaitingServer
                                    : context.l10n.sosAutoActivateSeconds(
                                        alertState.countdownSeconds),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.danger,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (alertState.error != null) ...[
              Text(alertState.error!, style: TextStyle(color: colors.danger)),
              const SizedBox(height: 12),
            ],
            // Nút BÁO ĐỘNG GIẢ
            AppButton(
              label: context.l10n.sosFalseAlarm,
              enabled: !alertState.isSubmitting && !alertState.isCancelling,
              variant: AppButtonVariant.secondary,
              width: double.infinity,
              height: 50,
              onPressed: () {
                ref.read(dangerAlertProvider.notifier).dismissAlert();
              },
            ),
            const SizedBox(height: 12),

            // Nút KÍCH HOẠT SOS NGAY
            AppButton(
              label: alertState.error == null
                  ? context.l10n.sosActivateNow
                  : context.l10n.sosRetry,
              isLoading: alertState.isSubmitting,
              enabled: !alertState.isCancelling,
              variant: AppButtonVariant.danger,
              width: double.infinity,
              height: 50,
              onPressed: () {
                ref.read(dangerAlertProvider.notifier).confirmAlert();
              },
            ),
          ],
        ),
      ),
    );
  }
}
