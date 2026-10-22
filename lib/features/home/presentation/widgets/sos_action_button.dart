import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// ============================================================================
/// FILE: lib/features/home/presentation/widgets/sos_action_button.dart
/// MODULE: Home - SOS Physical Hold Interaction Button
/// ROLE:
///   Nút bấm SOS khổng lồ trung tâm với tương tác vật lý chống bấm nhầm:
///     - Nhấn giữ liên tục 3 giây (Hold 3 Seconds)
///     - Vòng tròn tiến trình chạy quanh nút
///     - Rung phản hồi Haptic tăng dần lực theo từng giây
///     - Nhả tay giữa chừng -> Tự động hủy và tua lùi về 0
/// ============================================================================

class SosActionButton extends StatefulWidget {
  final VoidCallback onHoldCompleted;

  const SosActionButton({
    super.key,
    required this.onHoldCompleted,
  });

  @override
  State<SosActionButton> createState() => _SosActionButtonState();
}

class _SosActionButtonState extends State<SosActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _lastSecondTriggered = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addListener(() {
      final elapsedSeconds = (_controller.value * 3).floor();
      if (elapsedSeconds > _lastSecondTriggered && elapsedSeconds <= 3) {
        _lastSecondTriggered = elapsedSeconds;
        _triggerHaptic(elapsedSeconds);
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.vibrate();
        widget.onHoldCompleted();
        _controller.reset();
        _lastSecondTriggered = 0;
      }
    });
  }

  void _triggerHaptic(int second) {
    if (second == 1) {
      HapticFeedback.lightImpact();
    } else if (second == 2) {
      HapticFeedback.mediumImpact();
    } else if (second == 3) {
      HapticFeedback.heavyImpact();
    }
  }

  void _onTapDown(TapDownDetails details) {
    _lastSecondTriggered = 0;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
      _lastSecondTriggered = 0;
    }
  }

  void _onTapCancel() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
      _lastSecondTriggered = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final diameter = context.responsiveSosDiameter;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: SizedBox(
              width: diameter + 24,
              height: diameter + 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Circular Progress Indicator (Tiến trình 3 giây)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return SizedBox(
                        width: diameter + 18,
                        height: diameter + 18,
                        child: CircularProgressIndicator(
                          value: _controller.value,
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.danger),
                          backgroundColor: colors.dangerLight,
                        ),
                      );
                    },
                  ),

                  // 2. Main Red SOS Button
                  Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      color: colors.danger,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.danger.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emergency_rounded,
                            color: colors.onDanger,
                            size: 42,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.navSos,
                            style: TextStyle(
                              color: colors.onDanger,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.homeSosHoldHint,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
