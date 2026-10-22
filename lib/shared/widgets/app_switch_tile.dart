import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// ============================================================================
/// FILE: app_switch_tile.dart
/// MODULE: Shared Widgets - Switch Tile
/// ROLE:
///   Custom switch tile widget với title, subtitle và switch
/// ============================================================================

class AppSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Widget? leading;
  final Widget? trailing;

  const AppSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 12),
            ],
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: activeColor?.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return activeColor ?? colors.primary;
                }
                return colors.border;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
