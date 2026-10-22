import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/localized_domain_labels.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/safety_check_template_entity.dart';
import '../providers/safety_check_controller.dart';

class TemplateEditorSheet extends ConsumerStatefulWidget {
  const TemplateEditorSheet({super.key, this.template});
  final SafetyCheckTemplateEntity? template;

  static Future<bool?> show(BuildContext context,
          {SafetyCheckTemplateEntity? template}) =>
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => TemplateEditorSheet(template: template),
      );

  @override
  ConsumerState<TemplateEditorSheet> createState() =>
      _TemplateEditorSheetState();
}

class _TemplateEditorSheetState extends ConsumerState<TemplateEditorSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _duration = TextEditingController();
  final _grace = TextEditingController();
  final _presets = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final template = widget.template;
    if (template != null) {
      _name.text = context.l10n.templateName(template.id, template.name,
          isSystem: template.isSystem);
      _description.text = context.l10n.templateDescription(
          template.id, template.description,
          isSystem: template.isSystem);
    }
    _duration.text = '${template?.defaultDurationMinutes ?? 30}';
    _grace.text = '${template?.defaultGracePeriodSeconds ?? 60}';
    _presets.text =
        (template?.presetDurations ?? [15, 30, 45, 60, 90]).join(', ');
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _duration,
      _grace,
      _presets
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  List<int>? _parsePresets(String text) {
    final parts =
        text.split(',').map((part) => int.tryParse(part.trim())).toList();
    if (parts.length != 5 ||
        parts.any((part) => part == null || part < 1 || part > 1440)) {
      return null;
    }
    final values = parts.cast<int>();
    if (values.toSet().length != 5) return null;
    return values..sort();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final controller = ref.read(safetyCheckControllerProvider.notifier);
    final ok = await controller.saveTemplate({
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'default_duration_minutes': int.parse(_duration.text.trim()),
      'default_grace_period_seconds': int.parse(_grace.text.trim()),
      'preset_durations': _parsePresets(_presets.text)!,
      'icon': widget.template?.icon ?? 'shield',
    }, templateId: widget.template?.id);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (!ok) {
        _error = ref.read(safetyCheckControllerProvider).errorMessage ??
            context.l10n.scenarioSaveFailed;
      }
    });
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
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
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      widget.template == null
                          ? l10n.scenarioCreate
                          : l10n.scenarioEdit,
                      style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    enabled: !_saving,
                    decoration: InputDecoration(labelText: l10n.scenarioName),
                    validator: (value) => (value ?? '').trim().length < 2 ||
                            (value ?? '').trim().length > 100
                        ? l10n.scenarioInvalidName
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    enabled: !_saving,
                    maxLines: 2,
                    decoration:
                        InputDecoration(labelText: l10n.scenarioDescription),
                    validator: (value) => (value ?? '').length > 300
                        ? l10n.scenarioInvalidDescription
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _duration,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: l10n.scenarioDuration),
                    validator: (value) {
                      final minutes = int.tryParse((value ?? '').trim());
                      return minutes == null || minutes < 1 || minutes > 1440
                          ? l10n.scenarioInvalidDuration
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _grace,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: l10n.scenarioGrace,
                        helperText: l10n.scenarioGraceHint,
                        helperMaxLines: 3),
                    validator: (value) {
                      final seconds = int.tryParse((value ?? '').trim());
                      return seconds == null || seconds < 30 || seconds > 1800
                          ? l10n.scenarioInvalidGrace
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _presets,
                    enabled: !_saving,
                    decoration: InputDecoration(
                        labelText: l10n.scenarioPresets,
                        helperText: l10n.scenarioPresetsHint,
                        helperMaxLines: 3),
                    validator: (value) => _parsePresets(value ?? '') == null
                        ? l10n.scenarioInvalidPresets
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                        liveRegion: true,
                        child: Text(_error!,
                            style: TextStyle(color: colors.danger))),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                      label: l10n.save, isLoading: _saving, onPressed: _save),
                  const SizedBox(height: 8),
                  AppButton(
                      label: l10n.cancelShort,
                      variant: AppButtonVariant.secondary,
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
