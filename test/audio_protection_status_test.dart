import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/device/audio/danger_audio_manager.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_monitoring_status.dart';
import 'package:guardian_ai/l10n/app_localizations.dart';
import 'package:guardian_ai/shared/widgets/audio_protection_status.dart';

void main() {
  Future<void> show(WidgetTester tester, DangerAudioState state,
      {Locale locale = const Locale('en')}) async {
    await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: SizedBox(
                width: 320, child: AudioProtectionStatus(audio: state)))));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'healthy local recognition can coexist with failed alert delivery',
      (tester) async {
    await show(
        tester,
        const DangerAudioState(
            isMonitoring: true,
            monitoring: AudioMonitoringStatus(
                mode: AudioAnalysisMode.onDevice,
                health: AudioAnalysisHealth.healthy,
                delivery: AudioAlertDelivery.failed,
                deliveryFailure: AudioFailureKind.network)));
    expect(find.textContaining('Recognition on this device'), findsOneWidget);
    expect(find.textContaining('Analysis is keeping up'), findsOneWidget);
    expect(find.textContaining('has not acknowledged'), findsOneWidget);
    expect(find.textContaining('all selected contacts'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('server acceptance and recipient delivery are distinct states',
      (tester) async {
    const state = DangerAudioState(
        isMonitoring: true,
        monitoring: AudioMonitoringStatus(
            mode: AudioAnalysisMode.onDevice,
            health: AudioAnalysisHealth.healthy,
            delivery: AudioAlertDelivery.accepted));
    await show(tester, state);
    expect(find.textContaining('server accepted'), findsOneWidget);
    expect(find.textContaining('all selected contacts'), findsNothing);
    await show(tester, state.copyWith(deliveryStatus: 'SENT'));
    expect(find.textContaining('all selected contacts'), findsOneWidget);
  });

  testWidgets('Vietnamese fallback and model failure render at narrow width',
      (tester) async {
    await show(
        tester,
        const DangerAudioState(
            isMonitoring: true,
            monitoring: AudioMonitoringStatus(
                mode: AudioAnalysisMode.server,
                health: AudioAnalysisHealth.unavailable,
                analysisFailure: AudioFailureKind.model)),
        locale: const Locale('vi'));
    expect(find.textContaining('Nhận diện qua máy chủ'), findsOneWidget);
    expect(find.textContaining('Mô hình âm thanh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
