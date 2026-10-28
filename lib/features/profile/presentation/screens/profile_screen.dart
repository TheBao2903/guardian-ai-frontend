/// ============================================================================
/// FILE: lib/features/profile/presentation/screens/profile_screen.dart
/// MODULE: Profile - User Account, Medical Profile & Settings
/// ROLE:
///   Màn hình Hồ sơ cá nhân toàn diện với 3 Tabs nội bộ riêng biệt:
///   - Tab 1: Cá nhân & Telegram (Hồ sơ, Sửa thông tin, Kiểm tra thông báo bot)
///   - Tab 2: Y tế Khẩn cấp (Hồ sơ y tế, Cập nhật thông tin cứu trợ)
///   - Tab 3: Cài đặt & Bảo mật (Mã PIN SOS, Giao diện Sáng/Tối, Ngôn ngữ, Đăng xuất)
/// ============================================================================

import 'package:flutter/material.dart';
import '../../../../shared/widgets/flashlight_setup_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/device/device_info_service.dart';
import '../../../../core/device/location/location_service.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/profile_display_labels.dart';
import '../../../../shared/responsive/responsive_content_wrapper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/language_selector_sheet.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../contacts/domain/entities/contact_entity.dart';
import '../../../contacts/presentation/providers/contacts_controller.dart';
import '../../../sos/presentation/providers/sos_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Trạng thái mở khóa bảo mật hồ sơ y tế bằng mã PIN 4 số
  bool _isMedicalUnlocked = false;

  // Trạng thái định vị khẩn cấp & thiết bị tin cậy
  bool _isAuthorizingLocation = false;
  bool _isSavingLocation = false;
  ({
    double latitude,
    double longitude,
    double accuracy
  })? _currentLocationPreview;
  DeviceSummary? _deviceSummary;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await ref.read(deviceInfoServiceProvider).getDeviceSummary();
    if (mounted) {
      setState(() {
        _deviceSummary = info;
      });
    }
  }

  Future<void> _handleAuthorizeLocation(
    BuildContext context,
    UserEntity user,
    AuthController authController,
  ) async {
    if (_isAuthorizingLocation || _isSavingLocation) return;
    setState(() {
      _isAuthorizingLocation = true;
    });

    final locService = ref.read(locationServiceProvider);
    final pos = await locService.authorizeAndGetCurrentLocation();
    if (!mounted || !context.mounted) return;

    if (pos != null) {
      final lat = pos.latitude;
      final lng = pos.longitude;
      final acc = pos.accuracy;
      // Show the fix immediately; device registration can take longer on a
      // slow connection and must not hide coordinates already acquired.
      setState(() {
        _isAuthorizingLocation = false;
        _isSavingLocation = true;
        _currentLocationPreview =
            (latitude: lat, longitude: lng, accuracy: acc);
      });
      final devInfo = _deviceSummary ??
          await ref.read(deviceInfoServiceProvider).getDeviceSummary();
      if (!mounted || !context.mounted) return;
      final isApprox = acc >= 1000.0;
      final addr = isApprox
          ? context.l10n.locationNetworkLabel(
              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}')
          : context.l10n.locationGpsLabel(
              '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
              acc.round().toString());

      final saved = await authController.updateDeviceLocation(
        deviceName: devInfo.deviceName,
        platform: devInfo.platform,
        osVersion: devInfo.osVersion,
        locationPermissionGranted: true,
        latitude: lat,
        longitude: lng,
        accuracy: acc,
        address: addr,
      );

      if (!mounted || !context.mounted) return;
      final colors = context.colors;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      setState(() {
        _isAuthorizingLocation = false;
        _isSavingLocation = false;
        _currentLocationPreview =
            (latitude: lat, longitude: lng, accuracy: acc);
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: saved ? colors.primaryDark : colors.dangerDark,
          content: Text(
            !saved
                ? context.l10n.errorNetwork
                : isApprox
                    ? context.l10n.locationNetworkSuccess(devInfo.deviceName)
                    : context.l10n.locationGpsSuccess(devInfo.deviceName),
            style:
                TextStyle(fontWeight: FontWeight.w600, color: colors.onPrimary),
          ),
        ),
      );
    } else {
      if (!mounted || !context.mounted) return;
      final colors = context.colors;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      setState(() {
        _isAuthorizingLocation = false;
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: colors.dangerDark,
          content: Text(
            context.l10n.locationUnavailableDescription,
            style: TextStyle(color: colors.onDanger),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final contactsState = ref.watch(contactsControllerProvider);
    final sosState = ref.watch(sosControllerProvider);
    final sosController = ref.read(sosControllerProvider.notifier);

    final user = authState.user;

    // Nếu chưa đăng nhập, hiển thị màn hình loading hoặc chuyển về login
    if (user == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colors.primary),
              const SizedBox(height: 16),
              Text(
                context.l10n.profileLoading,
                style: TextStyle(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            l10n.profileTitle,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          elevation: 0,
          backgroundColor: colors.surface,
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout_rounded, color: colors.danger),
              tooltip: context.l10n.settingsLogout,
              onPressed: () => _confirmLogoutDialog(context, authController),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: colors.primary,
            indicatorWeight: 3,
            labelColor: colors.primary,
            unselectedLabelColor: colors.textSecondary,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
            tabs: [
              Tab(
                icon: Icon(Icons.person_rounded, size: 20),
                text: context.l10n.navProfile,
              ),
              Tab(
                icon: Icon(Icons.medical_services_rounded, size: 20),
                text: context.l10n.profileMedicalTab,
              ),
              Tab(
                icon: Icon(Icons.settings_rounded, size: 20),
                text: context.l10n.profileSettingsTab,
              ),
            ],
          ),
        ),
        body: ResponsiveContentWrapper(
          child: TabBarView(
            children: [
              // -------------------------------------------------------------
              // TAB 1: CÁ NHÂN & TELEGRAM
              // -------------------------------------------------------------
              _buildPersonalTab(
                context,
                user: user,
                authController: authController,
                contacts: contactsState.contacts,
              ),

              // -------------------------------------------------------------
              // TAB 2: HỒ SƠ Y TẾ KHẨN CẤP
              // -------------------------------------------------------------
              _buildMedicalTab(
                context,
                user: user,
                authController: authController,
                sosPin: sosState.pinCode,
              ),

              // -------------------------------------------------------------
              // TAB 3: BẢO MẬT & CÀI ĐẶT
              // -------------------------------------------------------------
              _buildSettingsTab(
                context,
                user: user,
                authController: authController,
                sosController: sosController,
                sosPin: sosState.pinCode,
                duressPin: sosState.duressPinCode,
                themeMode: themeMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: CÁ NHÂN & TELEGRAM
  // ===========================================================================
  Widget _buildPersonalTab(
    BuildContext context, {
    required UserEntity user,
    required AuthController authController,
    required List<ContactEntity> contacts,
  }) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thẻ thông tin cá nhân
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colors.primaryLight,
                      child: Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: colors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.displayName,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  context.l10n.profileSignedIn,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.email,
                            style: TextStyle(
                                color: colors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: colors.border, height: 1),
                const SizedBox(height: 14),

                _buildInfoRow(
                  context,
                  icon: Icons.phone_outlined,
                  label: context.l10n.phoneNumber,
                  value: user.phone?.isNotEmpty == true
                      ? user.phone!
                      : context.l10n.notUpdated,
                  color: colors.primary,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  icon: Icons.send_rounded,
                  label: context.l10n.profileTelegramPersonal,
                  value: user.telegramId?.isNotEmpty == true
                      ? user.telegramId!
                      : context.l10n.profileTelegramUnlinked,
                  color: colors.primary,
                ),

                const SizedBox(height: 16),
                // Nút Chỉnh sửa thông tin
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 42),
                    side: BorderSide(color: colors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(Icons.edit_outlined,
                      size: 18, color: colors.primary),
                  label: Text(
                    context.l10n.profileEditPersonal,
                    style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5),
                  ),
                  onPressed: () =>
                      _showEditProfileDialog(context, authController, user),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Card Định vị khẩn cấp & Thiết bị tin cậy (Pre-Authorization)
          _buildDeviceLocationCard(
            context,
            user: user,
            authController: authController,
          ),

          const SizedBox(height: 16),

          // Card Hướng dẫn & Kiểm tra thông báo Telegram
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.mark_chat_unread_outlined,
                        color: colors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.profileTestTelegramTitle,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.profileTestTelegramDescription,
                  style: TextStyle(
                      color: colors.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),

                // Hướng dẫn setup nhanh
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primaryLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.profileTelegramBot,
                        style: TextStyle(
                          color: colors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.l10n.profileTelegramSetupOne}'
                        '${context.l10n.profileTelegramSetupTwo}',
                        style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 11.5,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Nút Kiểm tra thông báo
                AppButton(
                  label: context.l10n.profileTestTelegramAction,
                  variant: AppButtonVariant.primary,
                  height: 44,
                  onPressed: () => _showTestTelegramOptions(
                    context,
                    authController: authController,
                    user: user,
                    contacts: contacts,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: HỒ SƠ Y TẾ KHẨN CẤP
  // ===========================================================================
  Widget _buildMedicalTab(
    BuildContext context, {
    required UserEntity user,
    required AuthController authController,
    required String sosPin,
  }) {
    final colors = context.colors;
    final l10n = context.l10n;

    // Kiểm tra xem người dùng đã nhập thông tin y tế hay chưa
    final hasMedicalData =
        (user.bloodType.isNotEmpty && user.bloodType != 'Chưa cập nhật') ||
            (user.allergies.isNotEmpty && user.allergies != 'Không có') ||
            (user.medicalNotes.isNotEmpty && user.medicalNotes != 'Không có');

    // Nếu ĐÃ CÓ DỮ LIỆU và CHƯA MỞ KHÓA -> Tự động khóa bảo vệ riêng tư (Privacy Lock)
    if (hasMedicalData && !_isMedicalUnlocked) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: colors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_rounded,
                        color: colors.primaryDark, size: 36),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.medicalLockedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.medicalLockedDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: context.l10n.medicalUnlockAction,
                    variant: AppButtonVariant.primary,
                    height: 48,
                    onPressed: () => _showUnlockMedicalDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: colors.primaryDark, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.medicalInitialHint,
                      style: TextStyle(
                          color: colors.primaryDark,
                          fontSize: 12,
                          height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Khi CHƯA CÓ DỮ LIỆU hoặc ĐÃ MỞ KHÓA -> Hiển thị chi tiết
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.medicalProfileTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  if (_isMedicalUnlocked && hasMedicalData) ...[
                    IconButton(
                      tooltip: context.l10n.medicalLockNow,
                      icon: Icon(Icons.lock_outline_rounded,
                          color: colors.textSecondary, size: 20),
                      onPressed: () {
                        setState(() => _isMedicalUnlocked = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.medicalLockedSuccess),
                            backgroundColor: colors.surfaceOverlay,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                  ],
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    icon: Icon(Icons.edit_outlined,
                        size: 16, color: colors.primary),
                    label: Text(
                      hasMedicalData
                          ? context.l10n.edit
                          : context.l10n.enterInformation,
                      style: TextStyle(
                          color: colors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () =>
                        _showEditMedicalDialog(context, authController, user),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.water_drop_outlined,
                  label: context.l10n.medicalBloodType,
                  value: user.bloodType,
                  color: colors.danger,
                ),
                Divider(color: colors.border, height: 20),
                _buildInfoRow(
                  context,
                  icon: Icons.warning_amber_rounded,
                  label: context.l10n.medicalAllergies,
                  value: user.allergies,
                  color: colors.warning,
                ),
                Divider(color: colors.border, height: 20),
                _buildInfoRow(
                  context,
                  icon: Icons.notes_rounded,
                  label: context.l10n.medicalNotes,
                  value: user.medicalNotes,
                  color: colors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primaryLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined,
                    color: colors.primaryDark, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.medicalSosHint,
                    style: TextStyle(
                        color: colors.primaryDark, fontSize: 12, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: BẢO MẬT & CÀI ĐẶT
  // ===========================================================================
  Widget _buildSettingsTab(
    BuildContext context, {
    required UserEntity user,
    required AuthController authController,
    required SosController sosController,
    required String sosPin,
    required String duressPin,
    required ThemeMode themeMode,
  }) {
    final colors = context.colors;
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Thẻ Đổi PIN SOS An Toàn
          AppCard(
            child: _ProfileSettingsRow(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.pin_outlined,
                      color: colors.primaryDark, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.settingsSafePinTitle,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: colors.primary, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(
                            sosPin.isNotEmpty
                                ? context.l10n.settingsSafePinSet
                                : context.l10n.notConfigured,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showChangePinDialog(
                    context,
                    authController: authController,
                    sosController: sosController,
                    currentPin: sosPin,
                    duressPin: duressPin,
                  ),
                  child: Text(context.l10n.settingsChangePin,
                      style:
                          TextStyle(color: colors.textPrimary, fontSize: 13)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Thẻ Mã PIN Cưỡng Bức (Duress PIN / Coercion Code)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileSettingsRow(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.dangerLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warning_amber_rounded,
                          color: colors.danger, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.settingsDuressPinTitle,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.shield_rounded,
                                  color: colors.danger, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                  child: Text(
                                duressPin.isNotEmpty
                                    ? context.l10n.settingsDuressPinSet
                                    : context.l10n.notEnabled,
                                style: TextStyle(
                                  color: colors.danger,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: colors.danger.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showChangeDuressPinDialog(
                        context,
                        authController: authController,
                        sosController: sosController,
                        currentDuressPin: duressPin,
                        currentSosPin: sosPin,
                      ),
                      child: Text(context.l10n.settingsChangeCode,
                          style: TextStyle(color: colors.danger, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.dangerLight.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colors.danger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.settingsDuressDescription,
                          style: TextStyle(
                              color: colors.danger, fontSize: 12, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Thẻ Đổi mật khẩu đăng nhập
          AppCard(
            child: _ProfileSettingsRow(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outline_rounded,
                      color: colors.primaryDark, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.settingsPasswordTitle,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: colors.primary, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(
                            context.l10n.settingsPasswordSet,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showChangePasswordDialog(
                    context,
                    authController: authController,
                  ),
                  child: Text(context.l10n.changeAction,
                      style:
                          TextStyle(color: colors.textPrimary, fontSize: 13)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const FlashlightSetupPanel(),
          const SizedBox(height: 14),

          // 4. Thẻ Giao diện ứng dụng (Chỉ Sáng / Tối, mặc định Sáng)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: colors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.settingsAppearance,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(context.l10n.settingsLight),
                        icon: Icon(Icons.light_mode_outlined, size: 16),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(context.l10n.settingsDark),
                        icon: Icon(Icons.dark_mode_outlined, size: 16),
                      ),
                    ],
                    selected: {
                      themeMode == ThemeMode.dark
                          ? ThemeMode.dark
                          : ThemeMode.light
                    },
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: colors.primaryLight,
                      selectedForegroundColor: colors.primaryDark,
                      foregroundColor: colors.textSecondary,
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: colors.border),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 4. Thẻ Ngôn ngữ (Mặc định Tiếng Việt)
          AppCard(
            onTap: () => LanguageSelectorSheet.show(context),
            child: Row(
              children: [
                Icon(Icons.language_rounded, color: colors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsLanguage,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Localizations.localeOf(context).languageCode == 'en'
                            ? context.l10n.settingsLanguageEn
                            : context.l10n.settingsLanguageVi,
                        style: TextStyle(
                            color: colors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 5. Nút Đăng xuất
          AppButton(
            label: context.l10n.settingsLogoutAccount,
            variant: AppButtonVariant.ghost,
            height: 48,
            onPressed: () => _confirmLogoutDialog(context, authController),
          ),

          const SizedBox(height: 24),

          // 6. Nhận diện thương hiệu & Phiên bản ứng dụng
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/app_logo.webp',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Guardian AI v1.0.0',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hệ sinh thái An toàn Cá nhân & Cứu trợ Khẩn cấp',
                  style: TextStyle(
                    color: colors.disabled,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIALOG: CHỈNH SỬA THÔNG TIN CÁ NHÂN
  // ===========================================================================
  void _showEditProfileDialog(
    BuildContext context,
    AuthController authController,
    UserEntity user,
  ) {
    final colors = context.colors;
    final nameCtrl = TextEditingController(text: user.displayName);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    final telegramCtrl = TextEditingController(text: user.telegramId ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (bottomCtx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 24,
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
                    context.l10n.profileEditPersonal,
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
                      labelText: context.l10n.fullName,
                      hintText: context.l10n.fullNameExample,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: context.l10n.phoneNumber,
                      hintText: '0987654321',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: telegramCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.telegramNumericId,
                      hintText: context.l10n.telegramIdExample,
                      prefixIcon: Icon(Icons.send_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.telegramIdHint,
                    style:
                        TextStyle(color: colors.textSecondary, fontSize: 11.5),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: context.l10n.saveChanges,
                    variant: AppButtonVariant.primary,
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(bottomCtx).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.nameRequired),
                            backgroundColor: colors.danger,
                          ),
                        );
                        return;
                      }

                      final ok = await authController.updateProfile(
                        displayName: name,
                        phone: phoneCtrl.text.trim(),
                        telegramId: telegramCtrl.text.trim(),
                      );

                      if (ok && bottomCtx.mounted) {
                        Navigator.of(bottomCtx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.profileUpdateSuccess),
                            backgroundColor: colors.primary,
                          ),
                        );
                      } else if (!ok && bottomCtx.mounted) {
                        final errMsg =
                            ref.read(authControllerProvider).errorMessage ??
                                context.l10n.profileUpdateFailed;
                        ScaffoldMessenger.of(bottomCtx).showSnackBar(
                          SnackBar(
                            content: Text(errMsg),
                            backgroundColor: colors.danger,
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

  // ===========================================================================
  // DIALOG: KIỂM TRA THÔNG BÁO TELEGRAM (Cá nhân hoặc Cá nhân + Người thân)
  // ===========================================================================
  void _showTestTelegramOptions(
    BuildContext context, {
    required AuthController authController,
    required UserEntity user,
    required List<ContactEntity> contacts,
  }) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomCtx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: colors.surfaceOverlay,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.telegramTestOptions,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.telegramTestChoose,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Tùy chọn 1: Chỉ cá nhân
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.border),
                ),
                leading: CircleAvatar(
                  backgroundColor: colors.primaryLight,
                  child: Icon(Icons.person_rounded,
                      color: colors.primaryDark, size: 20),
                ),
                title: Text(
                  context.l10n.telegramTestSelf,
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5),
                ),
                subtitle: Text(
                  user.telegramId?.isNotEmpty == true
                      ? 'ID: ${user.telegramId}'
                      : context.l10n.telegramNotConfigured,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(bottomCtx).pop();
                  _executeTestTelegram(
                    context,
                    authController: authController,
                    targets: [
                      _TestTarget(
                          name: context.l10n.profileSelf(user.displayName),
                          telegramId: user.telegramId),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // Tùy chọn 2: Cá nhân + Tất cả người thân
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.border),
                ),
                leading: CircleAvatar(
                  backgroundColor: colors.warningLight,
                  child: Icon(Icons.groups_rounded,
                      color: colors.warningDark, size: 20),
                ),
                title: Text(
                  context.l10n.telegramTestEveryone,
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5),
                ),
                subtitle: Text(
                  context.l10n.profileTestEveryoneDetail(
                      contacts.where((c) => c.hasTelegramConnected).length),
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(bottomCtx).pop();
                  final targets = <_TestTarget>[
                    _TestTarget(
                        name: context.l10n.profileSelf(user.displayName),
                        telegramId: user.telegramId),
                    ...contacts.map((c) => _TestTarget(
                        name: '${c.name} (${c.relationshipDisplay})',
                        telegramId: c.telegramId)),
                  ];
                  _executeTestTelegram(
                    context,
                    authController: authController,
                    targets: targets,
                  );
                },
              ),

              const SizedBox(height: 12),

              // Tùy chọn 3: Chỉ gửi tới người thân (Danh bạ khẩn cấp)
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.border),
                ),
                leading: CircleAvatar(
                  backgroundColor: colors.primaryLight,
                  child: Icon(Icons.emergency_share_rounded,
                      color: colors.primaryDark, size: 20),
                ),
                title: Text(
                  context.l10n.telegramTestContacts,
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5),
                ),
                subtitle: Text(
                  context.l10n.profileTestContactsDetail(
                      contacts.where((c) => c.hasTelegramConnected).length),
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(bottomCtx).pop();
                  final targets = <_TestTarget>[
                    ...contacts.map((c) => _TestTarget(
                        name: '${c.name} (${c.relationshipDisplay})',
                        telegramId: c.telegramId)),
                  ];
                  _executeTestTelegram(
                    context,
                    authController: authController,
                    targets: targets,
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Thực thi gửi test và hiển thị kết quả
  void _executeTestTelegram(
    BuildContext context, {
    required AuthController authController,
    required List<_TestTarget> targets,
  }) async {
    final colors = context.colors;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return AlertDialog(
            backgroundColor: colors.surfaceOverlay,
            title: Text(context.l10n.telegramChecking),
            content: SizedBox(
              width: double.maxFinite,
              child: FutureBuilder<List<_TestResult>>(
                future: _runTests(authController, targets),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colors.primary),
                        const SizedBox(height: 16),
                        Text(context.l10n.telegramSending),
                      ],
                    );
                  }

                  final results = snapshot.data ?? [];
                  final successCount = results.where((r) => r.isSuccess).length;

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n
                              .profileTestResults(successCount, results.length),
                          style: TextStyle(
                            color: successCount == results.length
                                ? colors.primary
                                : colors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...results.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    r.isSuccess
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: r.isSuccess
                                        ? colors.primary
                                        : colors.danger,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(r.name,
                                            style: TextStyle(
                                                color: colors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                        Text(r.message,
                                            style: TextStyle(
                                                color: colors.textSecondary,
                                                fontSize: 11.5)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 10),
                        Text(
                          context.l10n.telegramRecipientHint,
                          style: TextStyle(
                              color: colors.textTertiary,
                              fontSize: 11,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dlgCtx).pop(),
                child: Text(context.l10n.close),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<_TestResult>> _runTests(
    AuthController authController,
    List<_TestTarget> targets,
  ) async {
    final results = <_TestResult>[];

    for (final target in targets) {
      if (target.telegramId == null || target.telegramId!.isEmpty) {
        results.add(_TestResult(
          name: target.name,
          isSuccess: false,
          message: context.l10n.telegramChatNotConfigured,
        ));
        continue;
      }

      final testRes = await authController.testTelegramNotification(
        telegramId: target.telegramId!,
        message: context.l10n.profileTestMessage(target.name),
      );

      if (testRes.success) {
        results.add(_TestResult(
          name: target.name,
          isSuccess: true,
          message: context.l10n.profileTestDelivered(target.telegramId ?? ''),
        ));
      } else {
        String failMsg = testRes.message;
        if (failMsg.contains('401') ||
            failMsg.contains('xác thực') ||
            failMsg.contains('Bearer')) {
          failMsg = context.l10n.sessionExpiredHint;
        } else if (failMsg.toLowerCase().contains('chat not found') ||
            failMsg.toLowerCase().contains('bot was blocked') ||
            failMsg.contains('400')) {
          failMsg = context.l10n.telegramNotStarted;
        }
        results.add(_TestResult(
          name: target.name,
          isSuccess: false,
          message: failMsg,
        ));
      }
    }

    return results;
  }

  // ===========================================================================
  // DIALOGS: Y TẾ, PIN, LOGOUT
  // ===========================================================================
  void _showEditMedicalDialog(
    BuildContext context,
    AuthController authController,
    UserEntity user,
  ) {
    final colors = context.colors;
    String selectedBlood = user.bloodType;
    final allergiesCtrl = TextEditingController(text: user.allergies);
    final notesCtrl = TextEditingController(text: user.medicalNotes);

    final bloodTypes = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (bottomCtx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(bottomCtx).viewInsets.bottom + 24,
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
                    context.l10n.medicalEditTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: bloodTypes.contains(selectedBlood)
                        ? selectedBlood
                        : 'O+',
                    decoration: InputDecoration(
                        labelText: context.l10n.medicalBloodType),
                    items: bloodTypes
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedBlood = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: allergiesCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.medicalAllergies,
                      hintText: context.l10n.medicalAllergiesExample,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: context.l10n.medicalNotes,
                      hintText: context.l10n.medicalNotesExample,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: context.l10n.medicalSave,
                    variant: AppButtonVariant.primary,
                    onPressed: () async {
                      final ok = await authController.updateMedicalProfile(
                        bloodType: selectedBlood,
                        allergies: allergiesCtrl.text.trim(),
                        medicalNotes: notesCtrl.text.trim(),
                      );
                      if (ok && bottomCtx.mounted) {
                        Navigator.of(bottomCtx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.medicalSaveSuccess),
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

  // ===========================================================================
  // DIALOG: MỞ KHÓA HỒ SƠ Y TẾ BẰNG MÃ PIN 4 SỐ (BẢO VỆ RIÊNG TƯ)
  // ===========================================================================
  void _showUnlockMedicalDialog(BuildContext context) {
    final colors = context.colors;
    final pinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceOverlay,
        title: Row(
          children: [
            Icon(Icons.lock_open_rounded, color: colors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(context.l10n.medicalUnlockTitle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.medicalEnterPin,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                  fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '••••',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancelShort),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? colors.primary
                  : colors.primaryDark,
              foregroundColor: colors.onPrimary,
            ),
            onPressed: () async {
              final pin = pinCtrl.text.trim();
              final valid = await ref
                  .read(authControllerProvider.notifier)
                  .verifyPin(pin);
              if (!ctx.mounted || !mounted) return;
              if (valid) {
                Navigator.of(ctx).pop();
                setState(() => _isMedicalUnlocked = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.medicalUnlockedSuccess),
                    backgroundColor: colors.primary,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        ref.read(authControllerProvider).errorMessage ??
                            context.l10n.pinVerifyUnavailable),
                    backgroundColor: colors.danger,
                  ),
                );
              }
            },
            child: Text(context.l10n.unlockAction),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIALOG: ĐỔI MÃ PIN SOS AN TOÀN
  // ===========================================================================
  void _showChangePinDialog(
    BuildContext context, {
    required AuthController authController,
    required SosController sosController,
    required String currentPin,
    required String duressPin,
  }) {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();
    String? errorText;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final colors = dialogCtx.colors;
          return AlertDialog(
            backgroundColor: colors.surfaceOverlay,
            title: Text(context.l10n.pinChangeTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.pinCurrentHint,
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: oldPinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: context.l10n.pinCurrent,
                      hintText: '••••',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: context.l10n.pinNew,
                      hintText: '••••',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: context.l10n.pinConfirmNew,
                      hintText: '••••',
                      counterText: '',
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      style: TextStyle(
                          color: colors.danger,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.cancelShort),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(dialogCtx).brightness == Brightness.dark
                          ? colors.primary
                          : colors.primaryDark,
                  foregroundColor: colors.onPrimary,
                ),
                onPressed: () async {
                  if (isSaving) return;
                  isSaving = true;
                  try {
                    final oldPin = oldPinCtrl.text.trim();
                    final newPin = newPinCtrl.text.trim();
                    final confirmPin = confirmPinCtrl.text.trim();

                    // 1. Kiểm tra PIN cũ
                    final verified = await authController.verifyPin(oldPin);
                    if (!ctx.mounted) return;
                    if (!verified) {
                      setDialogState(() => errorText =
                          ref.read(authControllerProvider).errorMessage ??
                              context.l10n.pinCurrentIncorrect);
                      return;
                    }

                    // 2. Kiểm tra độ dài PIN mới
                    if (!RegExp(r'^[0-9]{4}$').hasMatch(newPin) ||
                        confirmPin.length != 4) {
                      setDialogState(
                          () => errorText = context.l10n.pinFourDigits);
                      return;
                    }

                    // 3. Kiểm tra khớp
                    if (newPin != confirmPin) {
                      setDialogState(() =>
                          errorText = context.l10n.pinConfirmationMismatch);
                      return;
                    }

                    // 4. Không được trùng PIN cũ
                    if (newPin == oldPin) {
                      setDialogState(
                          () => errorText = context.l10n.pinMustDiffer);
                      return;
                    }

                    // 5. Ràng buộc bảo mật: Không trùng với mã PIN cưỡng bức
                    // Thông báo trung tính, tránh tiết lộ sự tồn tại của tính năng báo động ngầm

                    // 6. Cập nhật cả 2 controllers để đồng bộ
                    final backendOk = await authController.updateSosPin(newPin);
                    if (!ctx.mounted) return;
                    if (!backendOk) {
                      setDialogState(() => errorText =
                          ref.read(authControllerProvider).errorMessage ??
                              context.l10n.pinUpdateUnavailable);
                      return;
                    }
                    await sosController.setPinCode(newPin);

                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.pinUpdateSuccess),
                          backgroundColor: colors.primary,
                        ),
                      );
                    }
                  } finally {
                    isSaving = false;
                  }
                },
                child: Text(context.l10n.pinSave),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // DIALOG: ĐỔI MÃ PIN CƯỠNG BỨC (DURESS PIN)
  // ===========================================================================
  void _showChangeDuressPinDialog(
    BuildContext context, {
    required AuthController authController,
    required SosController sosController,
    required String currentDuressPin,
    required String currentSosPin,
  }) {
    final oldDuressPinCtrl = TextEditingController();
    final newDuressPinCtrl = TextEditingController();
    final confirmDuressPinCtrl = TextEditingController();
    String? errorText;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final colors = dialogCtx.colors;
          return AlertDialog(
            backgroundColor: colors.surfaceOverlay,
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: colors.danger, size: 22),
                const SizedBox(width: 8),
                Text(context.l10n.duressChangeTitle),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.l10n.duressChangeDescription}'
                    '${context.l10n.duressCurrentHint}',
                    style: TextStyle(fontSize: 12.5, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: oldDuressPinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: context.l10n.duressCurrent,
                      hintText: '••••',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newDuressPinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: context.l10n.duressNew,
                      hintText: '••••',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmDuressPinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: context.l10n.duressConfirmNew,
                      hintText: '••••',
                      counterText: '',
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      style: TextStyle(
                          color: colors.danger,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.cancelShort),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.danger,
                  foregroundColor: colors.onDanger,
                ),
                onPressed: () async {
                  if (isSaving) return;
                  isSaving = true;
                  try {
                    final oldDuressPin = oldDuressPinCtrl.text.trim();
                    final newDuressPin = newDuressPinCtrl.text.trim();
                    final confirmDuressPin = confirmDuressPinCtrl.text.trim();

                    // 1. Kiểm tra PIN cũ
                    final verified = await authController
                        .verifyPin(oldDuressPin, duress: true);
                    if (!ctx.mounted) return;
                    if (!verified) {
                      setDialogState(() => errorText =
                          ref.read(authControllerProvider).errorMessage ??
                              context.l10n.duressCurrentIncorrect);
                      return;
                    }

                    // 2. Kiểm tra độ dài
                    if (!RegExp(r'^[0-9]{4}$').hasMatch(newDuressPin) ||
                        confirmDuressPin.length != 4) {
                      setDialogState(
                          () => errorText = context.l10n.pinFourDigits);
                      return;
                    }

                    // 3. Kiểm tra khớp
                    if (newDuressPin != confirmDuressPin) {
                      setDialogState(() =>
                          errorText = context.l10n.pinConfirmationMismatch);
                      return;
                    }

                    // 4. Không trùng PIN cũ
                    if (newDuressPin == oldDuressPin) {
                      setDialogState(
                          () => errorText = context.l10n.pinMustDiffer);
                      return;
                    }

                    // 5. Không trùng với mã PIN SOS thường
                    // Thông báo trung tính, tránh tiết lộ sự tồn tại của tính năng báo động ngầm

                    // 6. Cập nhật cả 2 controllers để đồng bộ (PLAN_PIN_VERIFICATION_OVERHAUL.md - Phase 6)
                    // 6a. Gọi backend trước để hash + lưu (an toàn, persistent)
                    final backendOk =
                        await authController.updateDuressPin(newDuressPin);
                    if (!backendOk) {
                      if (ctx.mounted) {
                        setDialogState(() =>
                            errorText = context.l10n.duressUpdateUnavailable);
                      }
                      return;
                    }
                    // 6b. Sync local controller (cache để verify offline)
                    await sosController.setDuressPinCode(newDuressPin);
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.duressUpdateSuccess),
                          backgroundColor: colors.primary,
                        ),
                      );
                    }
                  } finally {
                    isSaving = false;
                  }
                },
                child: Text(context.l10n.saveCode),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // DIALOG: ĐỔI MẬT KHẨU ĐĂNG NHẬP (Yêu cầu xác thực mật khẩu cũ)
  // ===========================================================================
  void _showChangePasswordDialog(
    BuildContext context, {
    required AuthController authController,
  }) {
    final oldPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();
    String? errorText;
    bool isObscureOld = true;
    bool isObscureNew = true;
    bool isObscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final colors = dialogCtx.colors;
          return AlertDialog(
            backgroundColor: colors.surfaceOverlay,
            title: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    color: colors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text(context.l10n.passwordChangeTitle)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.passwordCurrentHint,
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: oldPwdCtrl,
                    obscureText: isObscureOld,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: context.l10n.passwordCurrent,
                      hintText: '••••••',
                      prefixIcon:
                          const Icon(Icons.lock_outline_rounded, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                            isObscureOld
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18),
                        onPressed: () =>
                            setDialogState(() => isObscureOld = !isObscureOld),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPwdCtrl,
                    obscureText: isObscureNew,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: context.l10n.passwordNew,
                      hintText: context.l10n.passwordRequirements,
                      prefixIcon: const Icon(Icons.lock_rounded, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                            isObscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18),
                        onPressed: () =>
                            setDialogState(() => isObscureNew = !isObscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPwdCtrl,
                    obscureText: isObscureConfirm,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: context.l10n.passwordConfirm,
                      hintText: context.l10n.passwordRepeat,
                      prefixIcon: const Icon(Icons.lock_rounded, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                            isObscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18),
                        onPressed: () => setDialogState(
                            () => isObscureConfirm = !isObscureConfirm),
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.dangerLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: colors.danger, size: 16),
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
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.cancelShort),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(dialogCtx).brightness == Brightness.dark
                          ? colors.primary
                          : colors.primaryDark,
                  foregroundColor: colors.onPrimary,
                ),
                onPressed: () async {
                  final oldPwd = oldPwdCtrl.text;
                  final newPwd = newPwdCtrl.text;
                  final confirmPwd = confirmPwdCtrl.text;

                  // 1. Kiểm tra mật khẩu cũ không được trống
                  if (oldPwd.isEmpty) {
                    setDialogState(
                        () => errorText = context.l10n.passwordCurrentRequired);
                    return;
                  }

                  // 2. Kiểm tra mật khẩu mới đủ dài
                  if (newPwd.length < 6) {
                    setDialogState(
                        () => errorText = context.l10n.passwordTooShort);
                    return;
                  }

                  // 3. Kiểm tra có cả chữ và số
                  final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(newPwd);
                  final hasNumber = RegExp(r'[0-9]').hasMatch(newPwd);
                  if (!hasLetter || !hasNumber) {
                    setDialogState(
                        () => errorText = context.l10n.passwordLettersDigits);
                    return;
                  }

                  // 4. Kiểm tra khớp
                  if (newPwd != confirmPwd) {
                    setDialogState(() =>
                        errorText = context.l10n.passwordConfirmationMismatch);
                    return;
                  }

                  // 5. Khác mật khẩu cũ
                  if (newPwd == oldPwd) {
                    setDialogState(
                        () => errorText = context.l10n.passwordMustDiffer);
                    return;
                  }

                  // 6. Gọi API đổi mật khẩu
                  final result = await authController.changePassword(
                    currentPassword: oldPwd,
                    newPassword: newPwd,
                  );

                  if (ctx.mounted) {
                    if (result.success) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🔒 ${result.message}'),
                          backgroundColor: colors.primary,
                        ),
                      );
                    } else {
                      setDialogState(() => errorText = result.message);
                    }
                  }
                },
                child: Text(context.l10n.passwordChange),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogoutDialog(
      BuildContext context, AuthController authController) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceOverlay,
        title: Text(context.l10n.logoutConfirmTitle),
        content: Text(context.l10n.logoutConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancelShort),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.danger,
              foregroundColor: colors.onDanger,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await authController.logout();
              if (mounted) {
                context.go(RouteNames.login);
              }
            },
            child: Text(context.l10n.settingsLogout),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12)),
              Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CARD ĐỊNH VỊ KHẨN CẤP & THIẾT BỊ TIN CẬY (PRE-AUTHORIZATION)
  // ===========================================================================
  Widget _buildDeviceLocationCard(
    BuildContext context, {
    required UserEntity user,
    required AuthController authController,
  }) {
    final colors = context.colors;
    final isGranted = user.locationPermissionGranted;
    final deviceTitle = context.l10n.profileDeviceName(
        _deviceSummary?.deviceName ??
            (user.deviceInfo?['device_name'] as String? ??
                context.l10n.mobileDevice));
    final platformInfo = _deviceSummary?.platform ??
        (user.deviceInfo?['platform'] as String? ?? 'Web/Mobile');
    final osInfo = _deviceSummary?.osVersion ??
        (user.deviceInfo?['os_version'] as String? ?? '');

    final lastLoc = user.lastKnownLocation;
    final lat = _currentLocationPreview?.latitude ??
        (lastLoc?['latitude'] as num?)?.toDouble();
    final lng = _currentLocationPreview?.longitude ??
        (lastLoc?['longitude'] as num?)?.toDouble();
    final accuracy = _currentLocationPreview?.accuracy ??
        (lastLoc?['accuracy'] as num?)?.toDouble();
    final addressText = context.l10n.profileLocationLabel(
        latitude: lat,
        longitude: lng,
        accuracy: accuracy,
        savedAddress: lastLoc?['address'] as String?);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isGranted
                      ? colors.primaryLight.withValues(alpha: 0.5)
                      : colors.warningLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.gps_fixed_rounded,
                  color: isGranted ? colors.primaryDark : colors.warningDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.locationDeviceTitle,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGranted
                          ? context.l10n.locationAuthorized
                          : context.l10n.locationNotAuthorized,
                      style: TextStyle(
                        color:
                            isGranted ? colors.primaryDark : colors.warningDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Thông tin thiết bị & Tọa độ
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.disabledBg.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.smartphone_rounded,
                        size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.locationDeviceLabel,
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        deviceTitle,
                        style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.system_update_alt_rounded,
                        size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.locationOsLabel,
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$platformInfo $osInfo'.trim(),
                        style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (addressText != null) ...[
                  const Divider(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.pin_drop_rounded,
                          size: 18, color: colors.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.locationLastKnown,
                              style: TextStyle(
                                  color: colors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              addressText,
                              style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600),
                            ),
                            if (lat != null && lng != null) ...[
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => launchUrl(
                                  Uri.parse(LocationService.formatGoogleMapsUrl(
                                      lat, lng)),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: Text(
                                  context.l10n.locationOpenMaps,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Nút kích hoạt / cập nhật
          AppButton(
            label: _isAuthorizingLocation
                ? context.l10n.locationFinding
                : (isGranted
                    ? context.l10n.locationUpdate
                    : context.l10n.locationAuthorize),
            variant: isGranted
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            height: 44,
            isLoading: _isAuthorizingLocation,
            enabled: !_isSavingLocation,
            onPressed: () =>
                _handleAuthorizeLocation(context, user, authController),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              context.l10n.locationAuthorizeHint,
              style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Keep the action separate from long security labels on compact layouts.
class _ProfileSettingsRow extends StatelessWidget {
  const _ProfileSettingsRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 420 ||
              MediaQuery.textScalerOf(context).scale(14) > 16.8;
          final content = stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: children.sublist(0, children.length - 1)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: children.last,
                    ),
                  ],
                )
              : Row(children: children);
          return OutlinedButtonTheme(
            data: OutlinedButtonThemeData(
                style:
                    OutlinedButton.styleFrom(minimumSize: const Size(0, 44))),
            child: content,
          );
        },
      );
}

class _TestTarget {
  final String name;
  final String? telegramId;

  _TestTarget({required this.name, required this.telegramId});
}

class _TestResult {
  final String name;
  final bool isSuccess;
  final String message;

  _TestResult({
    required this.name,
    required this.isSuccess,
    required this.message,
  });
}
