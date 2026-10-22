import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/localized_domain_labels.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/contact_entity.dart';
import '../providers/contacts_controller.dart';

class ContactEditSheet extends ConsumerStatefulWidget {
  const ContactEditSheet({super.key, required this.contact});

  final ContactEntity contact;

  static Future<bool?> show(BuildContext context, ContactEntity contact) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => ContactEditSheet(contact: contact),
    );
  }

  @override
  ConsumerState<ContactEditSheet> createState() => _ContactEditSheetState();
}

class _ContactEditSheetState extends ConsumerState<ContactEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _telegram;
  late ContactRelationshipEnum _relationship;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.contact.name);
    _phone = TextEditingController(text: widget.contact.phone);
    _telegram = TextEditingController(text: widget.contact.telegramId ?? '');
    _relationship = widget.contact.relationship;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _telegram.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final controller = ref.read(contactsControllerProvider.notifier);
    try {
      final ok = await controller.updateContact(
        id: widget.contact.id,
        name: _name.text.trim(),
        relationship: _relationship,
        phone: AppValidators.normalizePhone(_phone.text),
        telegramId: _telegram.text.trim(),
      );
      if (!mounted) return;
      if (ok) {
        // Re-enable route popping before closing the saved form.
        setState(() => _saving = false);
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _saving = false;
          _error = ref.read(contactsControllerProvider).errorMessage ??
              context.l10n.contactsUpdateFailed;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = context.l10n.contactsUpdateFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return PopScope(
      canPop: !_saving,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceOverlay,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, 24, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.contactsEditTitle,
                      style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        InputDecoration(labelText: l10n.contactsFullName),
                    validator: (value) {
                      final length = (value ?? '').trim().length;
                      return length < 2 || length > 100
                          ? l10n.contactsInvalidName
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    enabled: !_saving,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: l10n.phoneNumber),
                    validator: (value) =>
                        AppValidators.isValidVnPhone(value ?? '')
                            ? null
                            : l10n.contactsInvalidPhone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ContactRelationshipEnum>(
                    initialValue: _relationship,
                    isExpanded: true,
                    decoration:
                        InputDecoration(labelText: l10n.contactRelationship),
                    items: ContactRelationshipEnum.values
                        .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(l10n.relationshipLabel(value))))
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _relationship = value!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telegram,
                    enabled: !_saving,
                    keyboardType:
                        const TextInputType.numberWithOptions(signed: true),
                    decoration: InputDecoration(
                      labelText: l10n.contactsTelegramLabel,
                      helperText: l10n.contactsTelegramRequiredHint,
                      helperMaxLines: 3,
                    ),
                    validator: (value) => (value ?? '').trim().isNotEmpty &&
                            AppValidators.isValidTelegramId(value)
                        ? null
                        : l10n.contactsInvalidTelegram,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child:
                          Text(_error!, style: TextStyle(color: colors.danger)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label: l10n.save,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: l10n.cancelShort,
                    variant: AppButtonVariant.secondary,
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
