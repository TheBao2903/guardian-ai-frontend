import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/locale_controller.dart';
import '../extensions/context_extensions.dart';

/// ============================================================================
/// FILE: lib/shared/widgets/language_selector_sheet.dart
/// MODULE: Language Switcher Modal Bottom Sheet
/// ROLE:
///   Cung cấp giao diện chọn ngôn ngữ trực tiếp cho người dùng (Tiếng Việt / English).
///   Cập nhật reactive qua Riverpod, lưu preference vào storage,
///   không reset route stack và không cần restart app.
/// ============================================================================

class LanguageSelectorSheet extends ConsumerStatefulWidget {
  const LanguageSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  ConsumerState<LanguageSelectorSheet> createState() =>
      _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends ConsumerState<LanguageSelectorSheet> {
  bool _saving = false;
  bool _saveFailed = false;

  Future<void> _selectLanguage(Locale locale) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      await ref.read(localeProvider.notifier).setLocale(locale);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colors.surfaceOverlay,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child:
                      Icon(Icons.close, color: colors.textSecondary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_saveFailed) ...[
              Text(l10n.languageSaveError,
                  style: TextStyle(color: colors.danger)),
              const SizedBox(height: 12),
            ],
            // Vietnamese Option
            _LanguageOptionTile(
              label: 'Tiếng Việt',
              flagEmoji: '🇻🇳',
              isSelected: currentLocale.languageCode == 'vi',
              onTap: _saving ? null : () => _selectLanguage(const Locale('vi')),
            ),
            const SizedBox(height: 12),

            // English Option
            _LanguageOptionTile(
              label: 'English',
              flagEmoji: '🇬🇧',
              isSelected: currentLocale.languageCode == 'en',
              onTap: _saving ? null : () => _selectLanguage(const Locale('en')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String label;
  final String flagEmoji;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LanguageOptionTile({
    required this.label,
    required this.flagEmoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: isSelected ? colors.primaryLight : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colors.primary : colors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(flagEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? colors.primaryDark : colors.textPrimary,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
