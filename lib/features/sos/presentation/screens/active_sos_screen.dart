/// ============================================================================
/// FILE: lib/features/sos/presentation/screens/active_sos_screen.dart
/// MODULE: Active SOS Fullscreen Alert Screen
/// ROLE:
///   Màn hình trạng thái khẩn cấp toàn diện khi SOS đang hoạt động:
///   - Trạng thái phát tín hiệu tới 10 người thân Telegram
///   - Tọa độ GPS thời gian thực từ thiết bị
///   - Điều khiển Còi Siren & Đèn Strobe
///   - Nút gọi khẩn cấp ưu tiên
///   - Nút Dừng SOS bắt buộc nhập Mã PIN 4 số cố định ('1234')
/// ============================================================================

library;

import 'package:flutter/material.dart';
import '../../../../core/device/flashlight/flashlight_controller.dart';
import '../../../../shared/widgets/flashlight_setup_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';

import '../../../../core/device/phone/phone_dialer.dart';
import '../../../../core/device/audio/danger_audio_providers.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/localized_domain_labels.dart';
import '../../../../shared/responsive/responsive_content_wrapper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../contacts/domain/entities/contact_entity.dart';
import '../providers/sos_controller.dart';
import '../providers/sos_state.dart';

class ActiveSosScreen extends ConsumerStatefulWidget {
  const ActiveSosScreen({super.key});

  @override
  ConsumerState<ActiveSosScreen> createState() => _ActiveSosScreenState();
}

class _ActiveSosScreenState extends ConsumerState<ActiveSosScreen> {
  @override
  void initState() {
    super.initState();
    // KHÔNG tự động kích hoạt SOS khi vào màn hình này.
    // Màn hình Active SOS chỉ thuần túy hiển thị trạng thái của phiên SOS đã được
    // kích hoạt hợp lệ (từ manual hold-3s, popup confirmation timeout, hoặc gunshot bypass).
    // Việc tự gọi activateSos() ở đây từng gây ra race navigation tạo phiên SOS không mong muốn.
  }

  @override
  Widget build(BuildContext context) {
    final flashlight = ref.watch(flashlightControllerProvider);
    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(sosControllerProvider);
    final controller = ref.read(sosControllerProvider.notifier);
    final phoneDialer = ref.read(phoneDialerProvider);

    final audio = ref.watch(dangerAudioProvider);
    final lat = state.currentLatitude;
    final lng = state.currentLongitude;
    final acc = state.currentAccuracy;
    final delivery = switch (audio.deliveryStatus) {
      'SENT' => context.l10n
          .sosDeliveredCount(audio.recipientsSent, audio.recipientsTotal),
      'NO_RECIPIENTS' => context.l10n.sosNoRecipients,
      'PARTIAL_FAILURE' => context.l10n.sosDeliveryFailedCount(
          audio.recipientsSent, audio.recipientsTotal, audio.recipientsFailed),
      'PENDING' => context.l10n
          .sosDeliveryPendingCount(audio.recipientsSent, audio.recipientsTotal),
      _ => context.l10n.sosSessionActive,
    };

    return Scaffold(
      backgroundColor: colors.dangerDark,
      body: SafeArea(
        child: ResponsiveContentWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // SOS Header Badge nhấp nháy đỏ
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.sosActiveTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Main Alert Card
              AppCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 46,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.sosActiveSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Divider(color: colors.border),
                    const SizedBox(height: 10),

                    // Tọa độ GPS Live
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: colors.danger, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lat != null && lng != null
                                ? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}${acc == null ? '' : ' (±${acc.toStringAsFixed(0)}m)'}'
                                : context.l10n.sosLocationMissing,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Trạng thái thu âm bằng chứng
                    Row(
                      children: [
                        Icon(Icons.send_rounded,
                            color: colors.danger, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            delivery,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Thanh điều khiển nhanh Còi Siren & Đèn Strobe
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.toggleSiren(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: state.isSirenPlaying
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: state.isSirenPlaying
                                ? Colors.white
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.isSirenPlaying
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.isSirenPlaying
                                  ? context.l10n.sirenOffAction
                                  : context.l10n.sirenOnAction,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.toggleStrobe(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: flashlight.isStrobeActive
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: flashlight.isStrobeActive
                                ? Colors.white
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              flashlight.isStrobeActive
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              flashlight.isStrobeActive
                                  ? context.l10n.strobeOffAction
                                  : context.l10n.strobeOnAction,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (flashlight.issue != null || flashlight.isBusy)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Semantics(
                        liveRegion: true,
                        child: Text(
                            flashlightStatusMessage(context, flashlight),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)))),
              const Spacer(),

              // Priority #1 Contact - Large Card
              _buildPrimaryContactCard(context, state, phoneDialer),

              const SizedBox(height: 12),

              // Next 4 Contacts - Compact List
              if (state.secondaryContacts.isNotEmpty) ...[
                Text(
                  context.l10n.emergencyContacts,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ...state.secondaryContacts.take(4).map(
                      (contact) => _buildCompactContactRow(
                          context, contact, phoneDialer),
                    ),
              ],

              const SizedBox(height: 12),

              // Audio Upload Status
              if (state.audioUploadStatus != null)
                _buildAudioUploadStatus(state.audioUploadStatus!),

              // Call Police Button
              const SizedBox(height: 8),
              AppButton(
                label: context.l10n.policeCallEmoji,
                variant: AppButtonVariant.secondary,
                width: double.infinity,
                height: 44,
                onPressed: () => phoneDialer.callPolice(),
              ),

              const SizedBox(height: 12),

              // Nút Dừng SOS (Bắt buộc Mã PIN 4 số)
              AppButton(
                label: l10n.sosStop,
                variant: AppButtonVariant.secondary,
                width: double.infinity,
                height: 50,
                onPressed: () =>
                    _showPinVerificationSheet(context, controller, state),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Priority #1 Contact Card
  Widget _buildPrimaryContactCard(
      BuildContext context, SosState state, PhoneDialer phoneDialer) {
    final contact = state.primaryContact;

    if (contact == null) {
      return AppButton(
        label: context.l10n.policeCallPhone,
        variant: AppButtonVariant.primary,
        width: double.infinity,
        height: 56,
        onPressed: () => phoneDialer.callPolice(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    contact.name.isNotEmpty
                        ? contact.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.primaryContact,
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    Text(
                      contact.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.l10n.relationshipLabel(contact.relationship),
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => phoneDialer.dial(contact.phone),
                  icon: const Icon(Icons.phone),
                  label: Text(context.l10n.callNowUpper),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openMessaging(contact.phone),
                  icon: const Icon(Icons.message),
                  label: Text(context.l10n.messageNowUpper),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Compact Contact Row for secondary contacts
  Widget _buildCompactContactRow(
      BuildContext context, ContactEntity contact, PhoneDialer phoneDialer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  context.l10n.relationshipLabel(contact.relationship),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => phoneDialer.dial(contact.phone),
            icon: Icon(Icons.phone, color: Colors.green.shade400, size: 22),
            tooltip: context.l10n.callAction,
          ),
          IconButton(
            onPressed: () => _openMessaging(contact.phone),
            icon: Icon(Icons.message, color: Colors.blue.shade300, size: 22),
            tooltip: context.l10n.messageAction,
          ),
        ],
      ),
    );
  }

  /// Build Audio Upload Status Bar
  Widget _buildAudioUploadStatus(AudioUploadStatus status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.state) {
      case 'uploading':
        statusColor = Colors.orange;
        statusText = 'Đang tải audio lên...';
        statusIcon = Icons.cloud_upload;
        break;
      case 'uploaded':
        statusColor = Colors.green;
        statusText = 'Audio đã gửi tới 3 người thân';
        statusIcon = Icons.check_circle;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusText = status.error ?? 'Upload thất bại';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.white60;
        statusText = 'Chờ upload audio...';
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Open messaging app
  Future<void> _openMessaging(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: cleanNumber,
    );

    try {
      await launchUrl(launchUri);
    } catch (_) {
      // Handle error silently
    }
  }

  void _showPinVerificationSheet(
    BuildContext context,
    SosController controller,
    SosState state,
  ) {
    final colors = context.colors;
    final l10n = context.l10n;
    final pinController = TextEditingController();
    String? pinError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceOverlay,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.sosEnterPinTitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.sosCurrentPinHint,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13.5),
                ),
                const SizedBox(height: 20),

                // Ô nhập PIN 4 số
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 18,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    hintStyle: TextStyle(
                      letterSpacing: 18,
                      color: colors.textSecondary.withOpacity(0.4),
                    ),
                  ),
                ),

                if (pinError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    pinError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Nút Xác nhận dừng SOS
                AppButton(
                  label: l10n.confirm,
                  variant: AppButtonVariant.danger,
                  height: 48,
                  onPressed: () async {
                    final entered = pinController.text.trim();
                    if (entered.length != 4) {
                      setDialogState(() {
                        pinError = context.l10n.sosPinRequired;
                      });
                      return;
                    }

                    final success = await controller.verifyPinAndCancelSos(
                      enteredPin: entered,
                    );

                    if (success) {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                      if (context.mounted) {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.home);
                        }
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.sosStoppedSuccess,
                            ),
                            backgroundColor: colors.primary,
                          ),
                        );
                      }
                    } else {
                      setDialogState(() {
                        pinError = l10n.sosIncorrectPin;
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
