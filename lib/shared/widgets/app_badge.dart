import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// ============================================================================
/// FILE: lib/shared/widgets/app_badge.dart
/// MODULE: Shared Badge / Status Pill Component
/// ROLE:
///   Hiển thị trạng thái an toàn, cảnh báo, khẩn cấp hoặc trung tính
///   - Success / Safe: Nền Green Light, chữ Green Dark
///   - Warning: Nền Yellow Light, chữ Yellow Dark
///   - Danger: Nền Red Light, chữ Red Dark
///   - Neutral: Nền Surface/DisabledBg, chữ TextSecondary
/// ============================================================================

enum AppBadgeVariant {
  success,
  warning,
  danger,
  neutral,
}

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case AppBadgeVariant.success:
        backgroundColor = colors.primaryLight;
        textColor = colors.primaryDark;
        break;
      case AppBadgeVariant.warning:
        backgroundColor = colors.warningLight;
        textColor = colors.warningDark;
        break;
      case AppBadgeVariant.danger:
        backgroundColor = colors.dangerLight;
        textColor = colors.dangerDark;
        break;
      case AppBadgeVariant.neutral:
        backgroundColor = colors.disabledBg;
        textColor = colors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
