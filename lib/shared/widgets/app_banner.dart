import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// ============================================================================
/// FILE: lib/shared/widgets/app_banner.dart
/// MODULE: In-Page Alert Banner Component
/// ROLE:
///   Hiển thị thông báo, cảnh báo nguy hiểm hoặc lưu ý quan trọng trong trang.
/// ============================================================================

enum AppBannerVariant {
  info,
  warning,
  danger,
}

class AppBanner extends StatelessWidget {
  final String message;
  final String? title;
  final AppBannerVariant variant;
  final IconData? icon;
  final VoidCallback? onClose;

  const AppBanner({
    super.key,
    required this.message,
    this.title,
    this.variant = AppBannerVariant.info,
    this.icon,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color backgroundColor;
    Color borderColor;
    Color contentColor;
    IconData defaultIcon;

    switch (variant) {
      case AppBannerVariant.info:
        backgroundColor = colors.primaryLight;
        borderColor = colors.primary.withValues(alpha: 0.3);
        contentColor = colors.primaryDark;
        defaultIcon = Icons.check_circle_outline;
        break;
      case AppBannerVariant.warning:
        backgroundColor = colors.warningLight;
        borderColor = colors.warning.withValues(alpha: 0.3);
        contentColor = colors.warningDark;
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case AppBannerVariant.danger:
        backgroundColor = colors.dangerLight;
        borderColor = colors.danger.withValues(alpha: 0.3);
        contentColor = colors.dangerDark;
        defaultIcon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, size: 20, color: contentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, size: 16, color: contentColor),
            ),
          ],
        ],
      ),
    );
  }
}
