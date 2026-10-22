import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// ============================================================================
/// FILE: lib/shared/extensions/context_extensions.dart
/// MODULE: BuildContext Extensions for UI, Theme & Localization Access
/// ROLE:
///   Cung cấp truy cập nhanh gọn, type-safe tới:
///   1. Semantic Color Scheme (`context.colors`)
///   2. Internationalization / Localized Strings (`context.l10n`)
///   3. ThemeData & TextTheme (`context.theme`, `context.textTheme`)
///   4. Dark Mode status (`context.isDarkMode`)
/// ============================================================================

extension BuildContextThemeExtensions on BuildContext {
  /// Truy cập Semantic Color Scheme hiện tại (Light hoặc Dark)
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.light();

  /// Truy cập Localization Strings hiện tại (en hoặc vi)
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Truy cập ThemeData
  ThemeData get theme => Theme.of(this);

  /// Truy cập TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Kiểm tra có đang ở Dark Mode hay không
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Đường kính nút SOS co giãn theo kích thước màn hình
  double get responsiveSosDiameter {
    final width = MediaQuery.sizeOf(this).width;
    if (width < 380) return 170.0;
    if (width >= 600) return 210.0;
    return 190.0;
  }
}
