import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/app/theme/app_theme.dart';
import 'package:guardian_ai/core/device/flashlight/flashlight_controller.dart';
import 'package:guardian_ai/l10n/app_localizations.dart';
import 'package:guardian_ai/shared/widgets/flashlight_setup_panel.dart';
import 'flashlight_controller_test.dart' show FakeFlashlightBackend;

void main() {
  for (final language in ['vi', 'en']) {
    testWidgets('camera setup fits a narrow phone in $language',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final light = FlashlightController(backend: FakeFlashlightBackend());
      await tester.pumpWidget(ProviderScope(
        overrides: [flashlightControllerProvider.overrideWith((ref) => light)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(
              body: SingleChildScrollView(
                  child: FlashlightSetupPanel(intro: true))),
        ),
      ));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(FlashlightSetupPanel));
      final l10n = AppLocalizations.of(context);
      expect(find.text(l10n.flashlightGrantAction), findsOneWidget);
      await tester.tap(find.text(l10n.flashlightGrantAction));
      await tester.pumpAndSettle();
      expect(find.text(l10n.flashlightReady), findsOneWidget);
      expect(find.text(l10n.flashlightCheckAction), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
