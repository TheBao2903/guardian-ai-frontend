/// ============================================================================
/// FILE: lib/features/safety_check/presentation/widgets/active_countdown_view.dart
/// MODULE: Safety Check - Active Countdown View
/// ROLE:
///   Giao diện đếm ngược toàn màn hình khi phiên Hẹn giờ đang chạy.
///   Bao gồm: Vòng tròn thời gian 220px, HH:MM:SS, Trạng thái Grace Period,
///   Nút 'Tôi an toàn', nút '+15 Phút' và nút 'Hủy'.
/// ============================================================================

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/localized_domain_labels.dart';
import '../../../../core/device/audio/danger_audio_providers.dart';
import '../../../../core/device/flashlight/flashlight_controller.dart';
import '../../../../shared/widgets/flashlight_setup_panel.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/audio_protection_status.dart';
import '../providers/safety_check_controller.dart';
import '../providers/safety_check_state.dart';

class ActiveCountdownView extends ConsumerWidget {
  const ActiveCountdownView({
    super.key,
    required this.state,
  });

  final SafetyCheckState state;

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final active = state.activeInstance!;
    final audio = ref.watch(dangerAudioProvider);
    final controller = ref.read(safetyCheckControllerProvider.notifier);

    final isGrace = state.isInGracePeriod;
    final isEscalated = active.isEscalated;

    Color progressColor;
    if (isEscalated) {
      progressColor = colors.danger;
    } else if (isGrace) {
      progressColor = colors.warning;
    } else {
      progressColor = colors.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        AudioProtectionStatus(audio: audio),
        const SizedBox(height: 12),

        // Thẻ thông tin phiên
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isGrace ? colors.warningLight : colors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGrace ? Icons.warning_amber_rounded : Icons.shield_rounded,
                  color: isGrace ? colors.warningDark : colors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.templateName(active.templateId, active.name),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGrace
                          ? context.l10n.safetyExpiredDescription
                          : context.l10n.safetyMonitoring,
                      style: TextStyle(
                        color:
                            isGrace ? colors.warningDark : colors.textSecondary,
                        fontSize: 13,
                        fontWeight: isGrace ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // Vòng tròn đếm ngược lớn
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vòng nền mờ
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    color: colors.surfaceOverlay,
                  ),
                ),
                // Vòng tiến trình thực tế
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: isGrace ? 1.0 : state.progressRatio,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    color: progressColor,
                  ),
                ),
                // Số đếm ngược
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isGrace
                          ? '${state.graceRemainingSeconds}s'
                          : _formatTime(state.remainingSeconds),
                      style: TextStyle(
                        color:
                            isGrace ? colors.warningDark : colors.textPrimary,
                        fontSize: isGrace ? 42 : 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGrace
                          ? context.l10n.safetyGracePeriod
                          : context.l10n.safetyCheckRemainingTime,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 36),

                // Tiện ích Đèn pin an toàn trong lúc đếm ngược
        Consumer(
          builder: (context, ref, _) {
            final flashlight = ref.watch(flashlightControllerProvider);
            final isTorchOn = flashlight.isTorchOn;
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isTorchOn ? colors.warningLight : colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTorchOn ? colors.warning : colors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isTorchOn
                        ? Icons.flashlight_on_rounded
                        : Icons.flashlight_off_rounded,
                    color: isTorchOn ? colors.warningDark : colors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đèn pin an toàn',
                          style: TextStyle(
                            color: isTorchOn
                                ? colors.warningDark
                                : colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          flashlight.isBusy
                              ? 'Đang kết nối camera & đèn...'
                              : isTorchOn
                                  ? 'Đang bật đèn soi đường'
                                  : 'Bật đèn flash khi đi lại ban đêm',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isTorchOn,
                    activeColor: colors.warning,
                    onChanged: (val) async {
                      await flashlight.toggleTorch();
                      if (context.mounted && flashlight.issue != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(flashlightStatusMessage(context, flashlight)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),

        // Nút chính: 'Tôi an toàn'
        AppButton(
          label: l10n.safetyCheckSafeConfirm,
          variant: AppButtonVariant.primary,
          width: double.infinity,
          height: 54,
          icon: Icons.check_circle_outline_rounded,
          isLoading: state.isActionLoading,
          onPressed: () async {
            final success = await controller.confirmSafe();
            if (context.mounted && success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.safetyConfirmed),
                  backgroundColor: colors.primary,
                ),
              );
            }
          },
        ),

        const SizedBox(height: 12),

        // Hàng nút phụ: Gia hạn +15m và Hủy
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: context.l10n.safetyExtendAction,
                variant: AppButtonVariant.secondary,
                height: 48,
                enabled: active.canExtend,
                onPressed: () async {
                  final ok = await controller.extendTimer(extendMinutes: 15);
                  if (context.mounted && ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.safetyExtended),
                        backgroundColor: colors.primary,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: l10n.cancel,
                variant: AppButtonVariant.ghost,
                height: 48,
                onPressed: () => _confirmCancelDialog(context, controller),
              ),
            ),
          ],
        ),

        if (active.extensionCount > 0) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              context.l10n.safetyExtensionCount(
                  active.extensionCount, active.maxExtensions),
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  void _confirmCancelDialog(
      BuildContext context, SafetyCheckController controller) {
    final colors = context.colors;
    final l10n = context.l10n;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceOverlay,
        title: Text(context.l10n.safetyCancelTitle),
        content: Text(context.l10n.safetyCancelDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.cancelTimer();
            },
            child: Text(context.l10n.safetyCancelConfirm),
          ),
        ],
      ),
    );
  }
}
