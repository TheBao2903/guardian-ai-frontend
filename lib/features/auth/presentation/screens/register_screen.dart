import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreePolicy = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (ref.read(authControllerProvider).isLoading) return;
    final colors = context.colors;
    final controller = ref.read(authControllerProvider.notifier);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.registerRequired),
          backgroundColor: colors.danger,
        ),
      );
      return;
    }

    if (!AppValidators.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.registerInvalidEmail),
          backgroundColor: colors.danger,
        ),
      );
      return;
    }

    if (phone.isNotEmpty && !AppValidators.isValidVnPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.contactsInvalidPhone),
          backgroundColor: colors.danger,
        ),
      );
      return;
    }

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.registerPasswordShort),
          backgroundColor: colors.danger,
        ),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.registerPasswordMismatch),
          backgroundColor: colors.danger,
        ),
      );
      return;
    }

    if (!_agreePolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.registerConsentRequired),
          backgroundColor: colors.danger,
        ),
      );
      return;
    }

    final ok = await controller.register(
      email: email,
      password: pass,
      displayName: name,
      phone: phone.isNotEmpty ? phone : null,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.registerSuccess),
          backgroundColor: colors.primary,
        ),
      );
      context.go(RouteNames.home);
    } else {
      final err = ref.read(authControllerProvider).errorMessage ??
          context.l10n.registerFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: colors.danger,
        ),
      );
    }
  }

  Widget _requiredLabel(String label) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: label.replaceFirst(RegExp(r'\s*\*$'), '')),
        TextSpan(
          text: ' *',
          style: TextStyle(
            color: context.colors.danger,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
      semanticsLabel: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final loading = authState.isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.background,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/images/app_logo.webp',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.shield_rounded,
                color: colors.primaryDark,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('Guardian AI',
              style: TextStyle(
                  fontFamily: 'NotoSans',
                  color: colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 20 : 32, vertical: compact ? 16 : 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Material(
                  color: compact ? colors.background : colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 0 : 32),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.registerTitle,
                              style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: compact ? 28 : 30,
                                  height: 1.25,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6)),
                          const SizedBox(height: 8),
                          Text(l10n.registerSubtitle,
                              style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                  height: 1.5)),
                          const SizedBox(height: 28),
                          TextField(
                            controller: _nameController,
                            enabled: !loading,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            decoration: InputDecoration(
                                label: _requiredLabel(l10n.registerName),
                                hintText: l10n.registerNamePrompt,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _emailController,
                            enabled: !loading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                                label: _requiredLabel(l10n.registerEmail),
                                hintText: l10n.registerEmailPrompt,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _phoneController,
                            enabled: !loading,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                            decoration: InputDecoration(
                                labelText: l10n.registerPhoneOptional,
                                hintText: '0901234567',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            enabled: !loading,
                            obscureText: _obscurePassword,
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: InputDecoration(
                              label: _requiredLabel(l10n.registerPassword),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              helperText: l10n.registerPasswordHint,
                              helperStyle: TextStyle(
                                  color: colors.textSecondary, fontSize: 12),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? l10n.authShowPassword
                                    : l10n.authHidePassword,
                                icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colors.textSecondary,
                                    size: 20),
                                onPressed: loading
                                    ? null
                                    : () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _confirmPasswordController,
                            enabled: !loading,
                            obscureText: _obscureConfirmPassword,
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _register(),
                            decoration: InputDecoration(
                              label:
                                  _requiredLabel(l10n.registerPasswordConfirm),
                              hintText: l10n.registerPasswordRepeat,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              suffixIcon: IconButton(
                                tooltip: _obscureConfirmPassword
                                    ? l10n.authShowPassword
                                    : l10n.authHidePassword,
                                icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colors.textSecondary,
                                    size: 20),
                                onPressed: loading
                                    ? null
                                    : () => setState(() =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            value: _agreePolicy,
                            onChanged: loading
                                ? null
                                : (value) => setState(
                                    () => _agreePolicy = value ?? false),
                            activeColor: colors.primary,
                            checkColor: colors.onPrimary,
                            controlAffinity: ListTileControlAffinity.leading,
                            titleAlignment: ListTileTitleAlignment.top,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            title: Text(l10n.registerConsent,
                                style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12.5,
                                    height: 1.5)),
                          ),
                          if (authState.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Semantics(
                              liveRegion: true,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: colors.dangerLight,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.error_outline_rounded,
                                          color: colors.danger, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(authState.errorMessage!,
                                              style: TextStyle(
                                                  color: colors.danger,
                                                  fontSize: 13,
                                                  height: 1.5))),
                                    ]),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          AppButton(
                              label: l10n.registerAction,
                              height: 50,
                              isLoading: loading,
                              onPressed: _register),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(l10n.registerHaveAccount,
                                  style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 14)),
                              TextButton(
                                onPressed: loading
                                    ? null
                                    : () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go(RouteNames.login);
                                        }
                                      },
                                style: TextButton.styleFrom(
                                    foregroundColor: colors.primaryDark,
                                    minimumSize: const Size(48, 48)),
                                child: Text(l10n.loginLink,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
