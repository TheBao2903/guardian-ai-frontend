import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'localization/locale_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';
import '../core/device/audio/detection/yamnet_classifier.dart';

/// ============================================================================
/// FILE: lib/app/app.dart
/// MODULE: Root Application Widget
/// ROLE:
///   Cấu hình MaterialApp.router gốc, tích hợp:
///   1. GoRouter Navigation Shell 3 Tabs (`routerConfig: ref.watch(routerProvider)`)
///   2. Reactive Locale State (`locale: ref.watch(localeProvider)`)
///   3. Supported Locales & Localizations Delegates
///   4. Light & Dark Themes với Semantic Color Scheme
///   5. Safe TextScaler Clamp (Giới hạn tỷ lệ font chữ 0.85 - 1.25 chống vỡ layout)
/// ============================================================================

class GuardianApp extends ConsumerWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    // Preload ngầm model YAMNet sau khi UI hoàn tất frame đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioClassifierProvider).initialize();
    });

    return MaterialApp.router(
      title: 'Guardian AI',
      debugShowCheckedModeBanner: false,

      // --- ROUTER CONFIGURATION ---
      routerConfig: router,

      // --- LOCALIZATION CONFIGURATION ---
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // --- THEME CONFIGURATION ---
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),

      // --- RESPONSIVE & TEXT SCALING SAFEGUARD ---
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScale = mediaQuery.textScaler.scale(1.0).clamp(0.85, 1.25);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(clampedScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
