/// ============================================================================
/// FILE: lib/features/auth/presentation/screens/login_screen.dart
/// MODULE: Auth - Login Screen
/// ROLE:
///   Màn hình đăng nhập tài khoản chuẩn evondevKit:
///   - Đăng nhập Email & Mật khẩu
///   - Điều hướng sang Đăng ký
/// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/responsive/responsive_content_wrapper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const String _lockoutStorageKey = 'guardian_login_lockout_until';
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _obscurePassword = true;

  // Rate Limiting & Escalating Backoff Lockout (60s -> 5m -> 10m -> 30m -> 1h -> 24h)
  static const List<int> _lockoutTiers = [60, 300, 600, 1800, 3600, 86400];
  int _failedAttempts = 0;
  int _lockoutTierIndex = 0;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _checkSavedLockout();
  }

  /// Khôi phục thời gian khóa từ SecureStorage (ngăn ngừa F5 / reload web bypass)
  Future<void> _checkSavedLockout() async {
    final storage = ref.read(secureStorageProvider);
    final savedUntilStr = await storage.read(_lockoutStorageKey);
    if (savedUntilStr != null) {
      final lockoutUntil = int.tryParse(savedUntilStr);
      if (lockoutUntil != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (lockoutUntil > now) {
          final remaining = ((lockoutUntil - now) / 1000).ceil();
          if (remaining > 0 && mounted) {
            _startLockoutTimer(remaining, saveToStorage: false);
          }
        } else {
          await storage.delete(_lockoutStorageKey);
        }
      }
    }
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _formatRemainingTime(int seconds) {
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final secs = seconds % 60;
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${secs.toString().padLeft(2, '0')}s';
    } else if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}p ${secs.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }

  void _startLockoutTimer(int seconds, {bool saveToStorage = true}) {
    setState(() {
      _lockoutSeconds = seconds;
    });

    if (saveToStorage) {
      final storage = ref.read(secureStorageProvider);
      final now = DateTime.now().millisecondsSinceEpoch;
      storage.write(
        key: _lockoutStorageKey,
        value: (now + seconds * 1000).toString(),
      );
    }

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockoutSeconds <= 1) {
        timer.cancel();
        ref.read(secureStorageProvider).delete(_lockoutStorageKey);
        setState(() {
          _lockoutSeconds = 0;
          _failedAttempts =
              0; // Hết thời gian phạt, cho phép thử lại chu kỳ mới
        });
      } else {
        setState(() {
          _lockoutSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ResponsiveContentWrapper(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo & Title
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_logo.webp',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: colors.primaryLight,
                            child: Icon(
                              Icons.shield_rounded,
                              color: colors.primaryDark,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    context.l10n.homeGreeting,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    context.l10n.loginTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Form Card
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.loginTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: colors.primary, size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: context.l10n.passwordLabel,
                            prefixIcon: Icon(Icons.lock_outline_rounded,
                                color: colors.primary, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: colors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        if (_lockoutSeconds > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: colors.danger.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer_outlined,
                                    color: colors.danger, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Khóa bảo mật chống Brute-force: Bạn đã thử sai 5 lần liên tiếp. Vui lòng chờ ${_formatRemainingTime(_lockoutSeconds)}.',
                                    style: TextStyle(
                                        color: colors.danger,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (authState.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            authState.errorMessage!,
                            style: TextStyle(
                                color: colors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Nút Đăng nhập
                        AppButton(
                          label: _lockoutSeconds > 0
                              ? 'Thử lại sau (${_formatRemainingTime(_lockoutSeconds)})'
                              : context.l10n.loginAction,
                          variant: AppButtonVariant.primary,
                          height: 50,
                          isLoading: authState.isLoading,
                          onPressed: _lockoutSeconds > 0
                              ? null
                              : () async {
                                  final email = _emailController.text.trim();
                                  final pass = _passwordController.text.trim();
                                  if (email.isEmpty || pass.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(context.l10n.loginRequired),
                                        backgroundColor: colors.danger,
                                      ),
                                    );
                                    return;
                                  }
                                  final success = await controller.login(
                                      email: email, password: pass);
                                  if (success && mounted) {
                                    // Đăng nhập thành công -> Reset hoàn toàn lịch sử vi phạm
                                    _failedAttempts = 0;
                                    _lockoutTierIndex = 0;
                                    _lockoutSeconds = 0;
                                    _lockoutTimer?.cancel();
                                    await ref
                                        .read(secureStorageProvider)
                                        .delete(_lockoutStorageKey);
                                    context.go(RouteNames.home);
                                  } else if (mounted) {
                                    final errMsg = ref
                                            .read(authControllerProvider)
                                            .errorMessage ??
                                        '';
                                    if (errMsg.contains('tạm khóa')) {
                                      // Thiết bị khác nhận được lệnh khóa từ Firestore DB -> Kích hoạt khóa ngay trên UI thiết bị này
                                      final matchSec = RegExp(r'(\d+)\s*giây')
                                          .firstMatch(errMsg);
                                      final matchMin = RegExp(r'(\d+)\s*phút')
                                          .firstMatch(errMsg);
                                      final matchHour = RegExp(r'(\d+)\s*giờ')
                                          .firstMatch(errMsg);
                                      int sec = 60;
                                      if (matchHour != null) {
                                        sec = (int.tryParse(
                                                    matchHour.group(1) ??
                                                        '1') ??
                                                1) *
                                            3600;
                                      } else if (matchMin != null) {
                                        sec = (int.tryParse(
                                                    matchMin.group(1) ?? '1') ??
                                                1) *
                                            60;
                                      } else if (matchSec != null) {
                                        sec = int.tryParse(
                                                matchSec.group(1) ?? '60') ??
                                            60;
                                      }
                                      _startLockoutTimer(sec);
                                    } else {
                                      setState(() {
                                        _failedAttempts++;
                                      });
                                      if (_failedAttempts >= 5) {
                                        // Kích hoạt khóa theo bậc leo thang: 60s -> 5m -> 10m -> 30m -> 1h -> 24h
                                        final duration = _lockoutTiers[
                                            _lockoutTierIndex.clamp(
                                                0, _lockoutTiers.length - 1)];
                                        _startLockoutTimer(duration);
                                        if (_lockoutTierIndex <
                                            _lockoutTiers.length - 1) {
                                          _lockoutTierIndex++;
                                        }
                                      }
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Link Quên mật khẩu (canh phải)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _showForgotPasswordDialog(context, ref),
                      child: Text(
                        context.l10n.forgotPasswordLink,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Link sang Đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.loginNoAccount,
                        style: TextStyle(
                            color: colors.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.register),
                        child: Text(
                          context.l10n.registerLink,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DIALOG: QUÊN MẬT KHẨU - Gửi email khôi phục
  // ===========================================================================
  void _showForgotPasswordDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final emailCtrl = TextEditingController();
    String? errorText;
    String? successText;
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: colors.surfaceOverlay,
          title: Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: colors.primary, size: 22),
              const SizedBox(width: 8),
              Text(context.l10n.forgotPasswordTitle),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.forgotPasswordDescription,
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: context.l10n.accountEmail,
                    hintText: 'example@gmail.com',
                    prefixIcon: Icon(Icons.email_rounded, size: 18),
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: colors.danger, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          errorText!,
                          style: TextStyle(
                            color: colors.danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (successText != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: colors.primary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          successText!,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  context.l10n.forgotPasswordSpamHint,
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.close),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty) {
                        setDialogState(() {
                          errorText = context.l10n.emailRequired;
                          successText = null;
                        });
                        return;
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(email)) {
                        setDialogState(() {
                          errorText = context.l10n.emailInvalid;
                          successText = null;
                        });
                        return;
                      }

                      setDialogState(() {
                        isSending = true;
                        errorText = null;
                        successText = null;
                      });

                      final result = await ref
                          .read(authControllerProvider.notifier)
                          .requestPasswordReset(email: email);

                      if (dialogCtx.mounted) {
                        setDialogState(() {
                          isSending = false;
                          if (result.success) {
                            successText = result.message;
                          } else {
                            errorText = result.message;
                          }
                        });
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.l10n.sendRequest),
            ),
          ],
        ),
      ),
    );
  }
}
