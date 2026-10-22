/// ============================================================================
/// FILE: lib/features/home/presentation/screens/home_screen.dart
/// MODULE: Home - Safety Control Center
/// ROLE:
///   Màn hình chính của ứng dụng theo triết lý "Calm until it matters":
///     - Trạng thái an toàn trong 3 giây
///     - Lối vào nhanh Hẹn giờ An toàn (Safety Check)
///     - Nút SOS trung tâm (Hold 3s + Đếm ngược 5s)
///     - Thanh công cụ bảo vệ nhanh (Còi hú, Đèn chớp, Gọi 113)
///     - Vòng tròn người thân tóm tắt (đồng bộ realtime)
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/localized_domain_labels.dart';
import '../../../../shared/responsive/responsive_content_wrapper.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_banner.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/language_selector_sheet.dart';
import '../../../contacts/presentation/providers/contacts_controller.dart';
import '../../../safety_check/presentation/providers/safety_check_controller.dart';
import '../widgets/quick_tools_bar.dart';
import '../widgets/sos_action_button.dart';
import '../widgets/sos_countdown_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatSeconds(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;

    final safetyCheckState = ref.watch(safetyCheckControllerProvider);
    final contactsState = ref.watch(contactsControllerProvider);

    final hasActiveCheck = safetyCheckState.hasActiveCheck;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.homeGreeting),
        elevation: 0,
        backgroundColor: colors.background,
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: l10n.settingsLanguage,
            icon: const Icon(Icons.language_rounded),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContentWrapper(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // 1. Safety Status Banner (Nhận diện trạng thái trong 3 giây)
              if (hasActiveCheck)
                AppBanner(
                  title: context.l10n.homeCountdownActive,
                  message: context.l10n.homeSessionRemaining(
                      context.l10n.templateName(
                          safetyCheckState.activeInstance?.templateId,
                          safetyCheckState.activeInstance?.name ?? ''),
                      _formatSeconds(safetyCheckState.remainingSeconds)),
                  variant: safetyCheckState.isInGracePeriod
                      ? AppBannerVariant.warning
                      : AppBannerVariant.info,
                )
              else
                AppBanner(
                  title: l10n.homeStatusSafe,
                  message: l10n.homeStatusSafeDesc,
                  variant: AppBannerVariant.info,
                ),

              const SizedBox(height: 16),

              // 2. Hero Safety Check Card (Kích hoạt bảo vệ trước rủi ro)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.safetyCheckTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppBadge(
                          label: hasActiveCheck
                              ? context.l10n.runningStatus
                              : l10n.homeStatusSafe,
                          variant: hasActiveCheck
                              ? AppBadgeVariant.warning
                              : AppBadgeVariant.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasActiveCheck
                          ? context.l10n.homeProtectionDescription
                          : l10n.safetyCheckSubtitle,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: hasActiveCheck
                          ? context.l10n.homeViewCountdown
                          : l10n.safetyCheckStart,
                      width: double.infinity,
                      onPressed: () => context.go(RouteNames.safetyCheck),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. Physical Hold-to-trigger SOS Button (Hold 3s)
              SosActionButton(
                onHoldCompleted: () => SosCountdownSheet.show(context),
              ),

              const SizedBox(height: 28),

              // 4. Quick Protection Tools (Còi hú, Đèn chớp, Gọi 113)
              Text(
                l10n.homeQuickActions,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const QuickToolsBar(),

              const SizedBox(height: 20),

              // 5. Guardian Circle Summary Preview
              AppCard(
                onTap: () => context.go(RouteNames.contacts),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colors.primaryLight,
                      child: Icon(Icons.people_alt_rounded,
                          color: colors.primaryDark, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.contactsTitle,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.homeContactsReady(
                                contactsState.contacts.length),
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: colors.textSecondary),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
