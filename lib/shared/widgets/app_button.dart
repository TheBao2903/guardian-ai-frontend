import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// ============================================================================
/// FILE: lib/shared/widgets/app_button.dart
/// MODULE: Shared Button Component
/// ROLE:
///   Nút bấm chuẩn hóa theo phân cấp thị giác (Button Hierarchy):
///     - Primary: Green (Bắt đầu, Xác nhận, Tiếp tục, Check-in)
///     - Danger: Red (Kích hoạt SOS, Dừng SOS, Hành động nguy hiểm)
///     - Warning: Yellow (Hành động chú ý / Cảnh báo)
///     - Secondary: Outline viền borderStrong, nền trong suốt/surface
///     - Ghost: Không nền, không viền, chữ màu semantic
///   Tự động đồng bộ màu chữ onPrimary/onDanger/onWarning đạt chuẩn WCAG AAA
///   cả trên Light Mode và Dark Mode.
/// ============================================================================

enum AppButtonVariant {
  primary,
  danger,
  warning,
  secondary,
  ghost,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDisabled = onPressed == null || isLoading || !enabled;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isDisabled ? colors.disabledBg : colors.primary;
        foregroundColor = isDisabled ? colors.disabled : colors.onPrimary;
        break;
      case AppButtonVariant.danger:
        backgroundColor = isDisabled ? colors.disabledBg : colors.danger;
        foregroundColor = isDisabled ? colors.disabled : colors.onDanger;
        break;
      case AppButtonVariant.warning:
        backgroundColor = isDisabled ? colors.disabledBg : colors.warning;
        foregroundColor = isDisabled ? colors.disabled : colors.onWarning;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colors.surface;
        foregroundColor = isDisabled ? colors.disabled : colors.textPrimary;
        borderSide = BorderSide(
          color: isDisabled ? colors.disabledBg : colors.borderStrong,
          width: 1,
        );
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? colors.disabled : colors.textPrimary;
        break;
    }

    return SizedBox(
      width: width,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide,
          ),
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    width == null ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(foregroundColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 18, color: foregroundColor),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
