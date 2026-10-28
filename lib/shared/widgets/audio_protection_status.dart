import 'package:flutter/material.dart';
import '../../core/device/audio/danger_audio_manager.dart';
import '../../core/device/audio/detection/audio_monitoring_status.dart';
import '../extensions/context_extensions.dart';
import 'app_card.dart';

/// Protection stages stay separate: capture, inference, server acceptance, delivery.
class AudioProtectionStatus extends StatelessWidget {
  const AudioProtectionStatus({super.key, required this.audio});
  final DangerAudioState audio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final status = audio.monitoring;
    final mode = switch (status.mode) {
      AudioAnalysisMode.initializing => l10n.audioPreparing,
      AudioAnalysisMode.onDevice => l10n.audioLocalMode,
      AudioAnalysisMode.server => l10n.audioServerMode,
    };
    String failure(AudioFailureKind kind) => switch (kind) {
          AudioFailureKind.network => l10n.audioNetworkFailure,
          AudioFailureKind.authentication => l10n.audioAuthFailure,
          AudioFailureKind.model => l10n.audioModelFailure,
          AudioFailureKind.stale => l10n.audioStaleFailure,
          AudioFailureKind.server => l10n.audioServerFailure,
          AudioFailureKind.none => l10n.audioAnalysisUnavailable,
        };
    final analysis = switch (status.health) {
      AudioAnalysisHealth.waiting => l10n.audioWaiting,
      AudioAnalysisHealth.healthy => l10n.audioAnalysisHealthy,
      AudioAnalysisHealth.delayed => l10n.audioAnalysisDelayed,
      AudioAnalysisHealth.unavailable => failure(status.analysisFailure),
    };
    var delivery = switch (status.delivery) {
      AudioAlertDelivery.idle => l10n.audioDeliveryRequiresNetwork,
      AudioAlertDelivery.sending => l10n.audioAlertSending,
      AudioAlertDelivery.retrying => l10n.audioAlertRetrying,
      AudioAlertDelivery.accepted => l10n.audioAlertAccepted,
      AudioAlertDelivery.failed =>
        '${l10n.audioAlertFailed} ${failure(status.deliveryFailure)}',
      AudioAlertDelivery.expired => l10n.audioAlertExpired,
    };
    if (audio.deliveryStatus == 'SENT') {
      delivery = l10n.audioRecipientsSent;
    }
    if (audio.deliveryStatus == 'NO_RECIPIENTS') {
      delivery = l10n.audioRecipientsMissing;
    }
    if (audio.deliveryStatus == 'PARTIAL_FAILURE') {
      delivery = l10n.audioRecipientsFailed;
    }
    final warning = audio.error != null ||
        !audio.isMonitoring ||
        status.health == AudioAnalysisHealth.delayed ||
        status.health == AudioAnalysisHealth.unavailable;
    final deliveryWarning = status.delivery == AudioAlertDelivery.failed ||
        status.delivery == AudioAlertDelivery.retrying ||
        status.delivery == AudioAlertDelivery.expired ||
        audio.deliveryStatus == 'NO_RECIPIENTS' ||
        audio.deliveryStatus == 'PARTIAL_FAILURE';
    return Semantics(
      container: true,
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(
                audio.isMonitoring
                    ? Icons.mic_outlined
                    : Icons.mic_off_outlined,
                size: 18,
                color: warning ? colors.warningDark : colors.primaryDark),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    audio.isMonitoring && audio.error == null
                        ? l10n.audioMicrophoneActive
                        : l10n.safetyMicrophoneUnavailable,
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 8),
          Text(
              audio.error ??
                  (audio.isMonitoring
                      ? '$mode · $analysis'
                      : l10n.audioAnalysisUnavailable),
              style: TextStyle(
                  color: warning ? colors.warningDark : colors.textSecondary)),
          const SizedBox(height: 4),
          Text(delivery,
              style: TextStyle(
                  color: deliveryWarning
                      ? colors.warningDark
                      : colors.textSecondary)),
        ]),
      ),
    );
  }
}
