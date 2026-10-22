import 'package:flutter/material.dart';

/// ============================================================================
/// FILE: lib/shared/responsive/app_breakpoints.dart
/// MODULE: Responsive Breakpoints & Device Adaptation
/// ROLE:
///   Định nghĩa các ngưỡng kích thước màn hình (Breakpoints), giới hạn độ rộng nội dung,
///   và các extensions hỗ trợ tối ưu giao diện cho:
///   - iPhone (iPhone SE 375px đến iPhone 16 Pro Max 440px, Dynamic Island, Home Bar)
///   - Android (Màn hẹp 360px, màn dài 20:9/21:9, Punch-hole, thanh 3 nút ảo)
///   - Tablet / iPad (iPad Mini, iPad Air/Pro, Galaxy Tab - Split View)
/// ============================================================================

abstract class AppBreakpoints {
  /// Màn hình điện thoại nhỏ (iPhone SE 1st/2nd/3rd gen, Galaxy dòng A giá rẻ)
  static const double compact = 380.0;

  /// Ngưỡng bắt đầu Tablet / Màn hình gập mở rộng (iPad, Galaxy Z Fold Unfolded)
  static const double tablet = 600.0;

  /// Ngưỡng Tablet màn hình lớn (iPad Pro 12.9 inch, Desktop view)
  static const double largeTablet = 1024.0;

  /// Độ rộng tối đa của nội dung trên Tablet/iPad để giữ công thái học (Thumb Zone)
  /// Tránh tình trạng nút SOS bị bẹt ngang và form bị kéo dãn bẹp dúm.
  static const double maxContentWidth = 520.0;

  /// Chiều cao nút bấm chuẩn tối thiểu cho vùng chạm cảm ứng an toàn (Accessibility)
  static const double minTouchTargetHeight = 48.0;

  /// Đường kính nút SOS khẩn cấp theo loại thiết bị
  static const double sosButtonDiameterCompact = 150.0;
  static const double sosButtonDiameterStandard = 175.0;
}

/// Extension tiện ích trên BuildContext để kiểm tra loại thiết bị tức thời
extension ResponsiveContextExtensions on BuildContext {
  /// Chiều rộng màn hình hiện tại
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Chiều cao màn hình hiện tại
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Có phải màn hình điện thoại siêu nhỏ không (Width < 380px)
  bool get isCompact => screenWidth < AppBreakpoints.compact;

  /// Có phải thiết bị Tablet / iPad không (Width >= 600px)
  bool get isTablet => screenWidth >= AppBreakpoints.tablet;

  /// Khoảng đệm an toàn phía trên (Tránh Notch, Dynamic Island, Status Bar)
  double get topSafeArea => MediaQuery.paddingOf(this).top;

  /// Khoảng đệm an toàn phía dưới (Tránh Home Indicator của iPhone hoặc 3 nút ảo Android)
  double get bottomSafeArea => MediaQuery.paddingOf(this).bottom;

  /// Đường kính nút SOS tối ưu cho màn hình hiện tại
  double get responsiveSosDiameter =>
      isCompact ? AppBreakpoints.sosButtonDiameterCompact : AppBreakpoints.sosButtonDiameterStandard;
}
