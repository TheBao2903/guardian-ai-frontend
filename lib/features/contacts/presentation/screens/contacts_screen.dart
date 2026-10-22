/// ============================================================================
/// FILE: lib/features/contacts/presentation/screens/contacts_screen.dart
/// MODULE: Guardian Circle (Emergency Contacts & Profile)
/// ROLE:
///   Tab 3 hiển thị:
///   - Vòng tròn tối đa 10 người thân nhận cảnh báo qua Telegram Bot (@GuardianAINotiBot)
///   - Đánh dấu người ưu tiên #1 gọi khẩn cấp
///   - Thêm/Xóa người thân
///   - Hồ sơ y tế khẩn cấp (Medical Profile) & Đổi ngôn ngữ
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/phone/phone_dialer.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/localized_domain_labels.dart';
import '../../../../shared/responsive/responsive_content_wrapper.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/language_selector_sheet.dart';
import '../../domain/entities/contact_entity.dart';
import '../providers/contacts_controller.dart';
import '../widgets/contact_edit_sheet.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(contactsControllerProvider);
    final controller = ref.read(contactsControllerProvider.notifier);
    final phoneDialer = ref.read(phoneDialerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.contactsTitle),
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
      floatingActionButton: state.canAddMore
          ? FloatingActionButton.extended(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(context.l10n.contactsAddCount(state.contacts.length)),
              onPressed: () => _showAddContactSheet(context, controller),
            )
          : null,
      body: ResponsiveContentWrapper(
        child: RefreshIndicator(
          onRefresh: () => controller.loadContacts(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // Guardian Circle Header Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shield_rounded,
                                  color: colors.primary, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Guardian Circle',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          AppBadge(
                            label: context.l10n
                                .contactsCount(state.contacts.length),
                            variant: state.contacts.length >= 2
                                ? AppBadgeVariant.success
                                : AppBadgeVariant.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.contactsAlertDescription,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Danh sách người thân
                if (state.isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                  )
                else if (state.contacts.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 48, color: colors.textTertiary),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.contactsEmptyTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.contactsEmptyDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: colors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ...state.sortedContacts.map((contact) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: contact.isPrimaryCaller
                                  ? colors.warningLight
                                  : colors.primaryLight,
                              child: Icon(
                                Icons.person,
                                color: contact.isPrimaryCaller
                                    ? colors.warningDark
                                    : colors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          contact.name,
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (contact.isPrimaryCaller) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: colors.warningLight,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            context.l10n.contactsPriorityBadge,
                                            style: TextStyle(
                                              color: colors.warningDark,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${context.l10n.relationshipLabel(contact.relationship)} • ${contact.phone}',
                                    style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 13),
                                  ),
                                  if (contact.hasTelegramConnected) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.send_rounded,
                                            size: 12, color: colors.primary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                            child: Text(
                                          'Telegram Chat ID: ${contact.telegramId}',
                                          style: TextStyle(
                                            color: colors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: context.l10n.contactsTestCall,
                              icon: Icon(Icons.phone_outlined,
                                  color: colors.primary, size: 20),
                              onPressed: () => phoneDialer.dial(contact.phone),
                            ),
                            // Option B: Nút đặt ưu tiên (nếu chưa phải primary)
                            if (!contact.isPrimaryCaller)
                              IconButton(
                                tooltip: context.l10n.contactsSetPriority,
                                icon: Icon(Icons.star_outline_rounded,
                                    color: colors.warning, size: 20),
                                onPressed: () => _confirmSetPrimaryDialog(
                                    context, controller, contact),
                              )
                            else
                              Icon(
                                Icons.star_rounded,
                                color: colors.warning,
                                size: 20,
                              ),
                            PopupMenuButton<String>(
                              tooltip: context.l10n.contactsActions,
                              enabled: !state.isActionLoading,
                              icon: Icon(Icons.more_vert_rounded,
                                  color: colors.textTertiary),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(context.l10n.edit),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(context.l10n.delete),
                                ),
                              ],
                              onSelected: (action) async {
                                if (action == 'delete') {
                                  _confirmDeleteDialog(
                                      context, controller, contact);
                                  return;
                                }
                                final saved = await ContactEditSheet.show(
                                    context, contact);
                                if (saved == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(context.l10n.contactsUpdated),
                                      backgroundColor: colors.primary,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                const SizedBox(height: 80), // Padding cho FloatingActionButton
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddContactSheet(
      BuildContext context, ContactsController controller) {
    final colors = context.colors;
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final telegramCtrl = TextEditingController();
    ContactRelationshipEnum relationship = ContactRelationshipEnum.parent;
    bool isPrimary = false; // Option A: Checkbox đặt làm ưu tiên

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (bottomContext, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(bottomContext).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceOverlay,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.contactsAddTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.contactsFullName,
                      hintText: context.l10n.contactsNameExample,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: context.l10n.phoneNumber,
                      hintText: '0901234567',
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: telegramCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.contactsTelegramLabel,
                      hintText: context.l10n.telegramIdExample,
                      prefixIcon: Icon(Icons.send_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Hướng dẫn cài đặt bot Telegram chi tiết cho người thân
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primaryLight.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colors.primary.withValues(alpha: 0.25),
                          width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: colors.primaryDark),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.contactsTelegramSetupTitle,
                              style: TextStyle(
                                color: colors.primaryDark,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${context.l10n.contactsTelegramSetupOne}'
                          '${context.l10n.contactsTelegramSetupTwo}'
                          '${context.l10n.contactsTelegramSetupThree}',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.contactsTelegramNumericHint,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dropdown Mối quan hệ
                  DropdownButtonFormField<ContactRelationshipEnum>(
                    value: relationship,
                    decoration: InputDecoration(
                        labelText: context.l10n.contactRelationship),
                    items: [
                      DropdownMenuItem(
                        value: ContactRelationshipEnum.parent,
                        child: Text(context.l10n.relationshipParent),
                      ),
                      DropdownMenuItem(
                        value: ContactRelationshipEnum.spouse,
                        child: Text(context.l10n.relationshipSpouse),
                      ),
                      DropdownMenuItem(
                        value: ContactRelationshipEnum.sibling,
                        child: Text(context.l10n.relationshipSibling),
                      ),
                      DropdownMenuItem(
                        value: ContactRelationshipEnum.child,
                        child: Text(context.l10n.relationshipChild),
                      ),
                      DropdownMenuItem(
                        value: ContactRelationshipEnum.friend,
                        child: Text(context.l10n.relationshipFriend),
                      ),
                      DropdownMenuItem(
                        value: ContactRelationshipEnum.colleague,
                        child: Text(context.l10n.relationshipColleague),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => relationship = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Option A: Checkbox đặt làm ưu tiên gọi #1
                  InkWell(
                    onTap: () => setModalState(() => isPrimary = !isPrimary),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isPrimary
                            ? colors.warningLight.withValues(alpha: 0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPrimary ? colors.warning : colors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isPrimary,
                            onChanged: (val) =>
                                setModalState(() => isPrimary = val ?? false),
                            activeColor: colors.warning,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star_rounded,
                            color: isPrimary
                                ? colors.warning
                                : colors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.contactsSetPriority,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isPrimary)
                                  Text(
                                    context.l10n.contactsOldPriorityHint,
                                    style: TextStyle(
                                      color: colors.warningDark,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: context.l10n.contactsSave,
                    variant: AppButtonVariant.primary,
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      final tg = telegramCtrl.text.trim();

                      if (name.isEmpty || phone.isEmpty) {
                        ScaffoldMessenger.of(bottomContext).showSnackBar(
                          SnackBar(
                            content:
                                Text(context.l10n.contactsNamePhoneRequired),
                            backgroundColor: colors.danger,
                          ),
                        );
                        return;
                      }

                      final cleanPhone = AppValidators.normalizePhone(phone);
                      if (!AppValidators.isValidVnPhone(cleanPhone)) {
                        ScaffoldMessenger.of(bottomContext).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.contactsInvalidPhone),
                            backgroundColor: colors.danger,
                          ),
                        );
                        return;
                      }

                      if (tg.isEmpty || !AppValidators.isValidTelegramId(tg)) {
                        ScaffoldMessenger.of(bottomContext).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.contactsInvalidTelegram),
                            backgroundColor: colors.danger,
                          ),
                        );
                        return;
                      }

                      final ok = await controller.addContact(
                        name: name,
                        relationship: relationship,
                        phone: cleanPhone,
                        telegramId: tg,
                        isPrimary: isPrimary,
                      );

                      if (ok && bottomContext.mounted) {
                        Navigator.of(bottomContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isPrimary
                                  ? context.l10n.contactsAddedPriority(name)
                                  : context.l10n.contactsAdded(name),
                            ),
                            backgroundColor: colors.primary,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteDialog(
    BuildContext context,
    ContactsController controller,
    ContactEntity contact,
  ) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceOverlay,
        title: Text(context.l10n.contactsDeleteTitle),
        content: Text(context.l10n.contactsRemoveNamed(contact.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancelShort),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteContact(contact.id);
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  // Option B: Dialog xác nhận đặt làm ưu tiên gọi #1
  void _confirmSetPrimaryDialog(
    BuildContext context,
    ContactsController controller,
    ContactEntity contact,
  ) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceOverlay,
        title: Row(
          children: [
            Icon(Icons.star_rounded, color: colors.warning, size: 24),
            const SizedBox(width: 8),
            Text(context.l10n.contactsSetPriority),
          ],
        ),
        content: Text(
          '${context.l10n.contactsPriorityNamed(contact.name)}\n\n'
          '${context.l10n.contactsPriorityMovedHint}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancelShort),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.warning,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await controller.setPrimaryContact(contact.id);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        context.l10n.contactsPrioritySuccess(contact.name)),
                    backgroundColor: colors.primary,
                  ),
                );
              } else if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.state.errorMessage ??
                        context.l10n.contactsPriorityFailed),
                    backgroundColor: colors.danger,
                  ),
                );
              }
            },
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }
}
