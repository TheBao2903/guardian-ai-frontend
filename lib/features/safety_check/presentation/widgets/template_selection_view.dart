/// ============================================================================
/// FILE: lib/features/safety_check/presentation/widgets/template_selection_view.dart
/// MODULE: Safety Check - Template Selection View
/// ROLE:
///   Giao diện chọn kịch bản bảo vệ:
///   - 5 mẫu ngữ cảnh (Đi về nhà, Đi xe, Thể thao, Gặp gỡ, Làm đêm)
///   - Mỗi mẫu có 5 mốc thời gian cố định + 1 mốc Tùy chỉnh (Custom)
///   - Ô nhập ghi chú tùy chọn & Nút bắt đầu.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/localized_domain_labels.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/safety_check_template_entity.dart';
import '../providers/safety_check_controller.dart';
import '../providers/safety_check_state.dart';
import 'template_editor_sheet.dart';

class TemplateSelectionView extends ConsumerStatefulWidget {
  const TemplateSelectionView({
    super.key,
    required this.state,
  });

  final SafetyCheckState state;

  @override
  ConsumerState<TemplateSelectionView> createState() =>
      _TemplateSelectionViewState();
}

class _TemplateSelectionViewState extends ConsumerState<TemplateSelectionView> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  IconData _getIconForTemplate(String icon) {
    switch (icon) {
      case 'footprints':
        return Icons.directions_walk_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'activity':
        return Icons.fitness_center_rounded;
      case 'users':
        return Icons.people_outline_rounded;
      case 'moon':
        return Icons.nightlight_round;
      default:
        return Icons.shield_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final controller = ref.read(safetyCheckControllerProvider.notifier);
    final selectedTemplate = widget.state.selectedTemplate;
    final presets = selectedTemplate?.presetDurations ?? [15, 30, 45, 60, 90];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),

        // Subtitle
        Text(
          l10n.safetyCheckSubtitle,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 20),

        // Danh sách các Template
        Text(
          context.l10n.safetyChooseScenario,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        AppButton(
          label: l10n.scenarioCreate,
          variant: AppButtonVariant.secondary,
          icon: Icons.add_rounded,
          onPressed:
              widget.state.isActionLoading ? null : () => _editTemplate(),
        ),
        const SizedBox(height: 12),
        if (widget.state.errorMessage != null) ...[
          Text(widget.state.errorMessage!,
              style: TextStyle(color: colors.danger)),
          TextButton(
              onPressed: widget.state.isActionLoading ? null : controller.init,
              child: Text(l10n.retry)),
        ],
        if (widget.state.templates.isEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l10n.scenarioEmpty,
                  style: TextStyle(color: colors.textSecondary))),

        ...widget.state.templates.map((template) {
          final isSelected = selectedTemplate?.id == template.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.state.isActionLoading
                  ? null
                  : () => controller.selectTemplate(template),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryLight.withOpacity(0.15)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primaryLight
                            : colors.surfaceOverlay,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForTemplate(template.icon),
                        color: isSelected
                            ? colors.primaryDark
                            : colors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.templateName(
                                template.id, template.name,
                                isSystem: template.isSystem),
                            style: TextStyle(
                              color: isSelected
                                  ? colors.primaryDark
                                  : colors.textPrimary,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.templateDescription(
                                template.id, template.description,
                                isSystem: template.isSystem),
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: template.id,
                      groupValue: selectedTemplate?.id,
                      activeColor: colors.primary,
                      onChanged: widget.state.isActionLoading
                          ? null
                          : (_) => controller.selectTemplate(template),
                    ),
                    PopupMenuButton<String>(
                      tooltip: l10n.scenarioActions,
                      enabled: !widget.state.isActionLoading,
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                        PopupMenuItem(
                            value: 'delete', child: Text(l10n.delete)),
                      ],
                      onSelected: (action) {
                        if (action == 'edit') {
                          _editTemplate(template);
                        } else {
                          _deleteTemplate(template);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Khu vực chọn thời gian: 5 mốc cố định + 1 mốc tùy chỉnh
        Text(
          context.l10n.safetyChooseDuration,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.safetyDurationLabel,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    context.l10n
                        .minutesDuration(widget.state.selectedDurationMinutes),
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5 Mốc cố định + 1 Mốc Tùy chỉnh
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...presets.map((minutes) {
                    final isChosen = !widget.state.isCustomDurationSelected &&
                        widget.state.selectedDurationMinutes == minutes;
                    return ChoiceChip(
                      label: Text(context.l10n.minutesDuration(minutes)),
                      selected: isChosen,
                      onSelected: (_) =>
                          controller.selectPresetDuration(minutes),
                      selectedColor: colors.primaryLight,
                      backgroundColor: colors.surface,
                      labelStyle: TextStyle(
                        color:
                            isChosen ? colors.primaryDark : colors.textPrimary,
                        fontWeight:
                            isChosen ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: isChosen ? colors.primary : colors.border,
                        width: 1,
                      ),
                    );
                  }),

                  // Mốc Tùy chỉnh (Custom)
                  ActionChip(
                    avatar: Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: widget.state.isCustomDurationSelected
                          ? colors.primaryDark
                          : colors.textPrimary,
                    ),
                    label: Text(
                      widget.state.isCustomDurationSelected
                          ? context.l10n.customMinutesDuration(
                              widget.state.selectedDurationMinutes)
                          : l10n.customDuration,
                    ),
                    backgroundColor: widget.state.isCustomDurationSelected
                        ? colors.primaryLight
                        : colors.surface,
                    side: BorderSide(
                      color: widget.state.isCustomDurationSelected
                          ? colors.primary
                          : colors.border,
                      width: 1,
                    ),
                    labelStyle: TextStyle(
                      color: widget.state.isCustomDurationSelected
                          ? colors.primaryDark
                          : colors.textPrimary,
                      fontWeight: widget.state.isCustomDurationSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    onPressed: () =>
                        _showCustomDurationDialog(context, controller),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Ghi chú an toàn
        Text(
          context.l10n.safetyNotesLabel,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: context.l10n.safetyNotesExample,
            hintStyle: TextStyle(color: colors.textTertiary, fontSize: 13),
            fillColor: colors.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Nút Bắt đầu
        AppButton(
          label: l10n.safetyCheckStart,
          variant: AppButtonVariant.primary,
          width: double.infinity,
          height: 52,
          icon: Icons.timer_outlined,
          isLoading: widget.state.isActionLoading,
          enabled: selectedTemplate != null,
          onPressed: () async {
            final ok = await controller.startSafetyCheck(
              customNotes: _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
            );
            if (context.mounted && ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n
                      .safetyStarted(widget.state.selectedDurationMinutes)),
                  backgroundColor: colors.primary,
                ),
              );
            }
          },
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _editTemplate([SafetyCheckTemplateEntity? template]) async {
    final saved = await TemplateEditorSheet.show(context, template: template);
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.scenarioSaved)));
  }

  Future<void> _deleteTemplate(SafetyCheckTemplateEntity template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.scenarioDeleteTitle),
        content: Text(
            '${ctx.l10n.templateName(template.id, template.name, isSystem: template.isSystem)}\n\n${ctx.l10n.scenarioDeleteConfirm}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(ctx.l10n.cancelShort)),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: ctx.colors.danger),
              child: Text(ctx.l10n.delete)),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final ok = await ref
        .read(safetyCheckControllerProvider.notifier)
        .deleteTemplate(template.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? context.l10n.scenarioDeleted
            : ref.read(safetyCheckControllerProvider).errorMessage ??
                context.l10n.scenarioSaveFailed)));
  }

  void _showCustomDurationDialog(
      BuildContext context, SafetyCheckController controller) {
    final inputCtrl = TextEditingController(
        text: widget.state.selectedDurationMinutes.toString());
    final colors = context.colors;
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceOverlay,
        title: Text(l10n.customDuration),
        content: TextField(
          controller: inputCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.customMinutesPrompt,
            suffixText: context.l10n.minutesUnit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = int.tryParse(inputCtrl.text);
              if (parsed != null && parsed > 0 && parsed <= 1440) {
                controller.setCustomDuration(parsed);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
