import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/device/flashlight/flashlight_controller.dart';
import '../extensions/context_extensions.dart';
import 'app_card.dart';

String flashlightStatusMessage(
    BuildContext context, FlashlightController light) {
  final l10n = context.l10n;
  if (light.isBusy) return l10n.flashlightChecking;
  if (light.issue != null) {
    return switch (light.issue!) {
      FlashlightIssue.permissionRequired => l10n.flashlightPermissionRequired,
      FlashlightIssue.permissionDenied => l10n.flashlightPermissionDenied,
      FlashlightIssue.unsupported => l10n.flashlightUnsupported,
      FlashlightIssue.insecureContext => l10n.flashlightInsecure,
      FlashlightIssue.cameraMissing => l10n.flashlightCameraMissing,
      FlashlightIssue.cameraBusy => l10n.flashlightCameraBusy,
      FlashlightIssue.interrupted => l10n.flashlightInterrupted,
      FlashlightIssue.timedOut => l10n.flashlightTimedOut,
      FlashlightIssue.failed => l10n.flashlightFailed,
    };
  }
  if (light.support == FlashlightSupport.unsupported) {
    return l10n.flashlightUnsupported;
  }
  if (light.support == FlashlightSupport.supported) return l10n.flashlightReady;
  if (light.cameraAccess == CameraAccess.denied) {
    return l10n.flashlightPermissionDenied;
  }
  return l10n.flashlightUnknown;
}

class FlashlightSetupPanel extends ConsumerWidget {
  const FlashlightSetupPanel({super.key, this.intro = false});
  final bool intro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = ref.watch(flashlightControllerProvider);
    final l10n = context.l10n;
    final colors = context.colors;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.flashlight_on_outlined, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(l10n.flashlightSetupTitle,
                  style: TextStyle(
                      color: colors.textPrimary, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 12),
        Text(l10n.flashlightSetupDescription,
            style: TextStyle(color: colors.textSecondary)),
        const SizedBox(height: 8),
        Semantics(
            liveRegion: true,
            child: Text(flashlightStatusMessage(context, light),
                style: TextStyle(
                    color: light.issue == null
                        ? colors.textSecondary
                        : colors.danger))),
        const SizedBox(height: 8),
        if (light.isWeb)
          Text(l10n.flashlightPermissionNote,
              style: TextStyle(color: colors.textSecondary, fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 8, children: [
          FilledButton(
            onPressed: () async {
              if (light.isBusy || light.isStrobeActive || light.isTorchOn) {
                await light.turnOff();
              } else {
                await light.prepare();
              }
            },
            child: Text(light.isBusy
                ? l10n.flashlightCancelAction
                : light.isStrobeActive || light.isTorchOn
                    ? l10n.flashlightStopAction
                    : light.cameraAccess == CameraAccess.granted || !light.isWeb
                        ? l10n.flashlightCheckAction
                        : l10n.flashlightGrantAction),
          ),
          if (intro)
            TextButton(
                onPressed: () async {
                  if (light.isBusy) await light.turnOff();
                  await light.dismissIntro();
                },
                child: Text(l10n.flashlightLaterAction)),
        ]),
      ]),
    );
  }
}
