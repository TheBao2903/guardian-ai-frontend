import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../sos/presentation/providers/sos_controller.dart';

/// ============================================================================
/// FILE: lib/features/home/presentation/widgets/sos_countdown_sheet.dart
/// MODULE: Home - 5s Pre-SOS Countdown Modal
/// ROLE:
///   Đếm ngược 5 giây sau khi hold nút SOS để người dùng có cơ hội hủy
///   nếu lỡ tay kích hoạt nhầm trước khi phát tán báo động tới người thân.
/// ============================================================================

class SosCountdownSheet extends ConsumerStatefulWidget {
  const SosCountdownSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SosCountdownSheet(),
    );
  }

  @override
  ConsumerState<SosCountdownSheet> createState() => _SosCountdownSheetState();
}

class _SosCountdownSheetState extends ConsumerState<SosCountdownSheet> {
  int _secondsRemaining = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
        HapticFeedback.heavyImpact();
      } else {
        timer.cancel();
        _triggerEmergencySos();
      }
    });
  }

  void _triggerEmergencySos() {
    if (!mounted) return;
    Navigator.of(context).pop(); // Đóng sheet đếm ngược
    // Kích hoạt SOS: RouterRefreshNotifier sẽ tự động chuyển hướng màn hình sang Active SOS
    ref.read(sosControllerProvider.notifier).activateSos(
          triggerType: 'MANUAL_SOS',
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colors.surfaceOverlay,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.dangerLight,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.emergency_rounded, color: colors.danger, size: 40),
            ),
            const SizedBox(height: 16),

            Text(
              context.l10n.sosPreparingTitle,
              style: TextStyle(
                color: colors.danger,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              context.l10n.sosCountdownDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Huge Countdown Number
            Text(
              '$_secondsRemaining',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: colors.danger,
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Button
            AppButton(
              label: context.l10n.sosCancelNow,
              variant: AppButtonVariant.secondary,
              width: double.infinity,
              height: 52,
              onPressed: () {
                _timer?.cancel();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.sosCancelledSuccess),
                    backgroundColor: colors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
