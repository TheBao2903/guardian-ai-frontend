import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

/// ============================================================================
/// FILE: lib/shared/responsive/responsive_content_wrapper.dart
/// MODULE: Cross-Device Responsive Content Container
/// ROLE:
///   Đảm bảo bố cục hiển thị hoàn hảo trên mọi kích thước màn hình:
///   1. Trên iPhone & Android: Chiếm trọn bề ngang với padding cạnh chuẩn nhịp.
///   2. Trên iPad / Tablet / Foldable: Giới hạn độ rộng tối đa (maxContentWidth = 520px)
///      và căn giữa màn hình, giữ trải nghiệm công thái học (Ergonomics) và tỷ lệ nút SOS.
///   3. Bảo vệ tự động khỏi Notch, Dynamic Island và thanh điều hướng ảo qua SafeArea.
/// ============================================================================

class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final bool enableSafeArea;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.enableSafeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.padding,
    this.maxWidth = AppBreakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final defaultHorizontalPadding = isCompact ? 12.0 : 16.0;

    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: defaultHorizontalPadding),
          child: child,
        ),
      ),
    );

    if (enableSafeArea) {
      content = SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: content,
      );
    }

    return content;
  }
}
