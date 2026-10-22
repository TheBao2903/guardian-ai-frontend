import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/audio/danger_audio_manager.dart';
import '../../../../core/device/audio/danger_audio_providers.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_switch_tile.dart';

/// ============================================================================
/// FILE: audio_shield_settings.dart
/// MODULE: Home - Audio Shield Settings Widget
/// ROLE:
///   Widget hiển thị cài đặt và trạng thái của Audio Shield AI
///   Có thể nhúng vào Settings screen hoặc Home screen
/// ============================================================================

class AudioShieldSettings extends ConsumerWidget {
  final bool showFullSettings;
  final VoidCallback? onToggleMonitoring;

  const AudioShieldSettings({
    super.key,
    this.showFullSettings = true,
    this.onToggleMonitoring,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dangerState = ref.watch(dangerAudioProvider);
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dangerState.isMonitoring
              ? colors.primary.withValues(alpha: 0.3)
              : colors.border.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, ref, dangerState),
          const SizedBox(height: 16),

          // Status
          _buildStatus(context, dangerState),
          const SizedBox(height: 16),

          // Toggle Button
          _buildToggleButton(context, ref, dangerState),

          // Full Settings
          if (showFullSettings) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildEventTypes(context, ref),
            const SizedBox(height: 16),
            _buildHistory(context, ref, dangerState),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DangerAudioState state) {
    final colors = context.colors;

    return Row(
      children: [
        // Shield Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: state.isMonitoring
                ? colors.primary.withValues(alpha: 0.1)
                : colors.surfaceOverlay,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.shield,
            color: state.isMonitoring ? colors.primary : colors.border,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),

        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🛡️ LÁ CHẮN ÂM THANH AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                state.isMonitoring
                    ? 'Đang theo dõi...'
                    : 'Lắng nghe khi ứng dụng hoạt động',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Status Indicator
        if (state.isMonitoring)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatus(BuildContext context, DangerAudioState state) {
    return Row(
      children: [
        // Microphone Status
        _buildStatusItem(
          context,
          icon: Icons.mic,
          label: 'Micro',
          value: state.hasPermission ? '✅ Có quyền' : '❌ Cấm',
          isActive: state.hasPermission,
        ),
        const SizedBox(width: 16),

        // Monitoring Duration
        if (state.isMonitoring)
          _buildStatusItem(
            context,
            icon: Icons.hearing,
            label: 'Đang nghe',
            value: '● Đang hoạt động',
            isActive: true,
          ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isActive,
  }) {
    final colors = context.colors;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceOverlay,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? colors.primary : colors.border,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive ? colors.textPrimary : colors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    WidgetRef ref,
    DangerAudioState state,
  ) {
    final colors = context.colors;
    final notifier = ref.read(dangerAudioProvider.notifier);

    return AppSwitchTile(
      title: state.isMonitoring ? 'Đang bảo vệ' : 'Bật bảo vệ',
      subtitle: state.isMonitoring
          ? 'Audio Shield đang theo dõi âm thanh'
          : 'Bật để phát hiện tiếng hét, khóc cầu cứu',
      value: state.isMonitoring,
      onChanged: (value) async {
        if (value) {
          final started = await notifier.startMonitoring();
          if (!started && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Không thể bật Audio Shield'),
                backgroundColor: colors.danger,
              ),
            );
          }
        } else {
          await notifier.stopMonitoring();
        }
        onToggleMonitoring?.call();
      },
      activeColor: colors.primary,
    );
  }

  Widget _buildEventTypes(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔔 Loại sự kiện phát hiện:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Scream
        _buildEventType(
          context,
          ref,
          event: DangerEventType.scream,
          label: 'Tiếng hét (SCREAM)',
          icon: Icons.campaign,
          cooldown: '30s',
        ),
        const SizedBox(height: 8),

        // Gunshot
        _buildEventType(
          context,
          ref,
          event: DangerEventType.gunshot,
          label: 'Tiếng súng (GUNSHOT)',
          icon: Icons.flash_on,
          cooldown: '60s',
        ),
        const SizedBox(height: 8),

        // Distress Cry
        _buildEventType(
          context,
          ref,
          event: DangerEventType.distressCry,
          label: 'Tiếng khóc cầu cứu',
          icon: Icons.sentiment_dissatisfied,
          cooldown: '15s',
        ),
      ],
    );
  }

  Widget _buildEventType(
    BuildContext context,
    WidgetRef ref, {
    required DangerEventType event,
    required String label,
    required IconData icon,
    required String cooldown,
  }) {
    final colors = context.colors;
    final cooldowns = ref.watch(dangerAudioProvider).cooldowns;
    final remaining = cooldowns['${event.name}'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceOverlay,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: colors.textPrimary,
              ),
            ),
          ),
          if (remaining > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(remaining / 1000).ceil()}s',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
            )
          else
            Text(
              cooldown,
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistory(
    BuildContext context,
    WidgetRef ref,
    DangerAudioState state,
  ) {
    final colors = context.colors;
    final history = state.detectionHistory;

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📈 Lịch sử phát hiện:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(dangerAudioProvider.notifier).clearHistory();
              },
              child: const Text('Xóa'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...history.take(5).map((detection) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceOverlay,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detection.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${(detection.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
