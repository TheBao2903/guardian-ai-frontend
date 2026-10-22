/// ============================================================================
/// FILE: lib/features/safety_check/presentation/screens/safety_check_screen.dart
/// MODULE: Safety Check - Main Screen
/// ROLE:
///   Màn hình chính của Hero Feature Safety Check:
///   - Khi không có phiên: TemplateSelectionView (5 kịch bản, 5 mốc cố định + 1 mốc tùy chỉnh)
///   - Khi đang chạy: ActiveCountdownView (Đồng hồ 220px, Tôi an toàn, +15m, Hủy)
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/responsive/responsive_content_wrapper.dart';
import '../providers/safety_check_controller.dart';
import '../widgets/active_countdown_view.dart';
import '../widgets/template_selection_view.dart';

class SafetyCheckScreen extends ConsumerWidget {
  const SafetyCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(safetyCheckControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.safetyCheckTitle),
        elevation: 0,
        backgroundColor: colors.background,
        centerTitle: false,
      ),
      body: ResponsiveContentWrapper(
        child: state.isLoading
            ? Center(
                child: CircularProgressIndicator(color: colors.primary),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: state.hasActiveCheck
                    ? ActiveCountdownView(state: state)
                    : TemplateSelectionView(state: state),
              ),
      ),
    );
  }
}
