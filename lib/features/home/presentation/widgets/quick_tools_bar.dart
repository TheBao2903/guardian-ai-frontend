import 'package:flutter/material.dart';
import '../../../../shared/widgets/flashlight_setup_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/device/audio/emergency_audio_player.dart';
import '../../../../core/device/flashlight/flashlight_controller.dart';
import '../../../../core/device/phone/phone_dialer.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_card.dart';

/// ============================================================================
/// FILE: lib/features/home/presentation/widgets/quick_tools_bar.dart
/// MODULE: Home - Quick Protection Tools
/// ROLE:
///   Cung cấp 3 công cụ tự vệ khẩn cấp một chạm:
///   1. 📢 Còi hú Siren max volume (Bật/Tắt tức thời)
///   2. 🔦 Đèn chớp Strobe Flashlight (Chớp camera liên tục)
///   3. 📞 Gọi khẩn cấp 113
/// ============================================================================

class QuickToolsBar extends ConsumerStatefulWidget {
  const QuickToolsBar({super.key});

  @override
  ConsumerState<QuickToolsBar> createState() => _QuickToolsBarState();
}

class _QuickToolsBarState extends ConsumerState<QuickToolsBar> {
  bool _isSirenOn = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    final audioPlayer = ref.read(emergencyAudioPlayerProvider);
    final flashlight = ref.watch(flashlightControllerProvider);
    final isStrobeOn = flashlight.isStrobeActive;
    final phoneDialer = ref.read(phoneDialerProvider);

    return Row(
      children: [
        // 1. Còi hú Siren
        Expanded(
          child: AppCard(
            backgroundColor: _isSirenOn ? colors.dangerLight : colors.surface,
            borderColor: _isSirenOn ? colors.danger : colors.border,
            onTap: () async {
              final active = await audioPlayer.toggleSiren();
              setState(() => _isSirenOn = active);
            },
            child: Column(
              children: [
                Icon(
                  _isSirenOn
                      ? Icons.volume_up_rounded
                      : Icons.volume_mute_rounded,
                  color: _isSirenOn ? colors.danger : colors.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  _isSirenOn ? context.l10n.sirenRunning : l10n.homeSirenAction,
                  style: TextStyle(
                    color: _isSirenOn ? colors.dangerDark : colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 2. Đèn chớp Strobe
        Expanded(
          child: AppCard(
            backgroundColor: isStrobeOn ? colors.warningLight : colors.surface,
            borderColor: isStrobeOn ? colors.warning : colors.border,
            onTap: () async {
              await flashlight.toggleStrobe();
              if (!context.mounted || flashlight.issue == null) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(flashlightStatusMessage(context, flashlight))));
            },
            child: Column(
              children: [
                Icon(
                  isStrobeOn
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded,
                  color: isStrobeOn ? colors.warningDark : colors.warning,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  flashlight.isBusy
                      ? context.l10n.flashlightChecking
                      : isStrobeOn
                          ? context.l10n.strobeRunning
                          : l10n.homeStrobeAction,
                  style: TextStyle(
                    color: isStrobeOn ? colors.warningDark : colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 3. Gọi khẩn cấp 113
        Expanded(
          child: AppCard(
            onTap: () => _confirmCallPolice(context, phoneDialer),
            child: Column(
              children: [
                Icon(
                  Icons.local_police_rounded,
                  color: colors.danger,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.homeCallPoliceAction,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmCallPolice(BuildContext context, PhoneDialer phoneDialer) {
    final colors = context.colors;
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceOverlay,
        title: Text(context.l10n.policeCallTitle),
        content: Text(
          context.l10n.policeCallDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.danger),
            onPressed: () {
              Navigator.of(ctx).pop();
              phoneDialer.callPolice();
            },
            child: Text(
              context.l10n.callNow,
              style: TextStyle(
                  color: colors.onDanger, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
