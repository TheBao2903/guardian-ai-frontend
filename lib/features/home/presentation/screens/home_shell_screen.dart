import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// ============================================================================
/// FILE: lib/features/home/presentation/screens/home_shell_screen.dart
/// MODULE: Bottom Navigation Shell Container
/// ROLE:
///   Bao bọc 3 Tab chính của ứng dụng bằng StatefulNavigationShell:
///     - Tab 0: Home (Trang chủ - Safety Control Center)
///     - Tab 1: Safety Check (Hẹn giờ bảo vệ)
///     - Tab 2: Contacts & Profile (Người thân & Y tế)
///   Bảo toàn state của các tab khi chuyển đổi, phẳng viền 1px chuẩn evondevKit.
/// ============================================================================

class HomeShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: colors.surface,
              indicatorColor: colors.primaryLight,
              elevation: 0,
              height: 64,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryDark,
                  );
                }
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: colors.primaryDark, size: 22);
                }
                return IconThemeData(color: colors.textSecondary, size: 22);
              }),
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.shield_outlined),
                  selectedIcon: const Icon(Icons.shield_rounded),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.timer_outlined),
                  selectedIcon: const Icon(Icons.timer_rounded),
                  label: l10n.navSafetyCheck,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline_rounded),
                  selectedIcon: const Icon(Icons.people_rounded),
                  label: l10n.navContacts,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: l10n.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
