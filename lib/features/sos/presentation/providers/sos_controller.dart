/// ============================================================================
/// FILE: lib/features/sos/presentation/providers/sos_controller.dart
/// MODULE: Emergency & SOS - Presentation Controller
/// ROLE:
///   Điều phối toàn diện trạng thái khẩn cấp:
///   - Kích hoạt SOS: Bật còi báo động, chớp đèn Strobe, thu thập GPS, gửi API
///   - Hủy SOS: Bắt buộc xác thực Mã PIN 4 số cố định ('1234')
///   - Tắt còi, tắt đèn và cập nhật an toàn.
/// ============================================================================

library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/device/audio/danger_audio_providers.dart';
import '../../../../core/device/audio/emergency_audio_player.dart';
import '../../../../core/device/flashlight/flashlight_controller.dart';
import '../../../../core/device/location/location_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../contacts/presentation/providers/contacts_controller.dart';
import '../../domain/usecases/emergency_usecases_providers.dart';
import '../../domain/entities/emergency_session_entity.dart';
import 'sos_state.dart';

final sosControllerProvider =
    StateNotifierProvider<SosController, SosState>((ref) {
  final controller = SosController(ref);
  ref.listen(flashlightControllerProvider, (_, light) {
    controller.syncFlashlight(light.isStrobeActive);
  });
  return controller;
});

class SosController extends StateNotifier<SosState> {
  SosController(this._ref) : super(const SosState()) {
    _init();
  }

  final Ref _ref;

  void syncFlashlight(bool active) {
    if (mounted && state.isStrobeActive != active) {
      state = state.copyWith(isStrobeActive: active);
    }
  }

  Future<void> _init() async {
    // 1. Đọc mã PIN an toàn và Mã PIN cưỡng bức đã lưu
    final storage = _ref.read(secureStorageProvider);
    final savedPin = await storage.read(StorageKeys.sosPinCode);
    final savedDuressPin = await storage.read(StorageKeys.duressPinCode);
    final hasChanged =
        (await storage.read(StorageKeys.hasChangedPin)) == 'true';
    final hasChangedDuress =
        (await storage.read(StorageKeys.hasChangedDuressPin)) == 'true';

    if (!mounted) return;
    state = state.copyWith(
      pinCode: (savedPin != null && savedPin.isNotEmpty) ? savedPin : '1234',
      duressPinCode: (savedDuressPin != null && savedDuressPin.isNotEmpty)
          ? savedDuressPin
          : '9999',
      hasChangedPin: hasChanged,
      hasChangedDuressPin: hasChangedDuress,
    );

    // 2. Tự động kiểm tra trạng thái GPS ban đầu
    final locationService = _ref.read(locationServiceProvider);
    final pos = await locationService.getCurrentLocation();
    if (mounted && pos != null) {
      state = state.copyWith(
        currentLatitude: pos.latitude,
        currentLongitude: pos.longitude,
        currentAccuracy: pos.accuracy,
      );
    }
  }

  /// Cập nhật mã PIN SOS an toàn
  Future<void> setPinCode(String newPin) async {
    final storage = _ref.read(secureStorageProvider);
    await storage.write(key: StorageKeys.sosPinCode, value: newPin);
    // Đánh dấu user đã đổi PIN - từ đây fallback '1234' không còn hiệu lực
    await storage.write(key: StorageKeys.hasChangedPin, value: 'true');
    state = state.copyWith(pinCode: newPin, hasChangedPin: true);
  }

  /// Cập nhật mã PIN Cưỡng bức (Duress PIN)
  Future<void> setDuressPinCode(String newDuressPin) async {
    final storage = _ref.read(secureStorageProvider);
    await storage.write(key: StorageKeys.duressPinCode, value: newDuressPin);
    // Đánh dấu user đã đổi Duress PIN - fallback '9999' bị vô hiệu hóa
    await storage.write(key: StorageKeys.hasChangedDuressPin, value: 'true');
    state =
        state.copyWith(duressPinCode: newDuressPin, hasChangedDuressPin: true);
  }

  /// Kích hoạt phiên SOS toàn diện
  ///
  /// [triggerType] - Loại trigger: 'MANUAL_SOS', 'AI_SCREAM_DETECTED', 'SAFETY_CHECK_ESCALATED', etc.
  /// [recordingId] - ID của audio clip nếu có (để link với evidence)
  Future<bool>? _activationInFlight;

  Future<bool> activateSos({
    String triggerType = 'MANUAL_SOS',
    String? recordingId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
  }) {
    if (state.activeSession?.isActive == true) return Future.value(true);
    return _activationInFlight ??= _activateSos(
      triggerType: triggerType,
      recordingId: recordingId,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
    ).whenComplete(() => _activationInFlight = null);
  }

  Future<bool> _activateSos({
    required String triggerType,
    String? recordingId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
  }) async {
    state = state.copyWith(
        isLoading: true,
        isPendingActivation: true,
        activeRecordingId: recordingId);
    try {
      // Sending is the first awaited operation. GPS, hardware and contact loading
      // must not delay the request at the end of the ten-second response window.
      final result = await _ref.read(triggerSosUseCaseProvider)(
        triggerType: triggerType,
        latitude: latitude ?? state.currentLatitude,
        longitude: longitude ?? state.currentLongitude,
        accuracyMeters: accuracyMeters ?? state.currentAccuracy,
        recordingId: recordingId,
      );
      if (!mounted) return false;
      return result.when<bool>(
        success: (session) {
          state = state.copyWith(
            isLoading: false,
            isPendingActivation: false,
            activeSession: session,
            currentLatitude:
                session.latitude ?? latitude ?? state.currentLatitude,
            currentLongitude:
                session.longitude ?? longitude ?? state.currentLongitude,
            currentAccuracy: session.accuracyMeters ??
                accuracyMeters ??
                state.currentAccuracy,
          );
          unawaited(_prepareActiveSession(session.id));
          return true;
        },
        error: (failure) {
          state = state.copyWith(
              isLoading: false,
              isPendingActivation: false,
              errorMessage: failure.message);
          return false;
        },
      );
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
            isLoading: false,
            isPendingActivation: false,
            errorMessage: 'Không gửi được SOS. Kiểm tra kết nối và thử lại.');
      }
      return false;
    }
  }

  void restoreServerSession(EmergencySessionEntity session) {
    if (!mounted) return;
    if (!session.isActive) {
      if (state.activeSession?.id == session.id) {
        unawaited(_ref.read(flashlightControllerProvider).turnOff());
        state = state.copyWith(clearActiveSession: true);
      }
      return;
    }
    final isNew = state.activeSession?.id != session.id;
    state = state.copyWith(
        activeSession: session,
        isLoading: false,
        isPendingActivation: false,
        currentLatitude: session.latitude,
        currentLongitude: session.longitude,
        currentAccuracy: session.accuracyMeters);
    if (isNew) unawaited(_prepareActiveSession(session.id));
  }

  Future<void> _prepareActiveSession(String sessionId) async {
    bool stillActive() =>
        mounted && state.activeSession?.id == sessionId && state.isSosActive;
    try {
      final flashlight = _ref.read(flashlightControllerProvider);
      await flashlight.startStrobe(allowPermissionPrompt: false);
      if (!stillActive()) return;
      state = state.copyWith(isStrobeActive: flashlight.isStrobeActive);
    } catch (error) {
      debugPrint('SOS flashlight unavailable: $error');
    }
    try {
      if (!stillActive()) return;
      await _ref.read(contactsControllerProvider.notifier).loadContacts();
      if (!stillActive()) return;
      state = state.copyWith(
          priorityContacts:
              _ref.read(contactsControllerProvider).priorityContactsForSos);
    } catch (error) {
      debugPrint('SOS contact display unavailable: $error');
    }
    try {
      if (!stillActive()) return;
      await _ref.read(dangerAudioProvider.notifier).stopMonitoring();
      if (stillActive()) state = state.copyWith(isAudioRecording: false);
    } catch (error) {
      debugPrint('SOS microphone cleanup unavailable: $error');
    }
  }

  /// Bật / Tắt còi Siren thủ công khi đang trong màn hình SOS
  Future<void> toggleSiren() async {
    final audioPlayer = _ref.read(emergencyAudioPlayerProvider);
    if (state.isSirenPlaying) {
      await audioPlayer.stopSiren();
      state = state.copyWith(isSirenPlaying: false);
    } else {
      await audioPlayer.playSiren();
      state = state.copyWith(isSirenPlaying: true);
    }
  }

  /// Bật / Tắt đèn chớp Strobe thủ công
  Future<void> toggleStrobe() async {
    final flashlight = _ref.read(flashlightControllerProvider);
    await flashlight.toggleStrobe();
    if (mounted) syncFlashlight(flashlight.isStrobeActive);
  }

  /// Hủy SOS bằng Mã PIN 4 số (Bao gồm Safe PIN hoặc Duress PIN cưỡng bức)
  ///
  /// PLAN_PIN_VERIFICATION_OVERHAUL.md - Phase 7:
  /// - PIN được verify bằng BACKEND (bcrypt hash), KHÔNG verify local.
  /// - Client gửi PIN thô lên backend, backend check với hash + fallback logic.
  /// - Nếu PIN sai → backend trả 401, client KHÔNG cancel session.
  /// - Nếu PIN đúng → backend cancel + gửi notification phù hợp
  ///   (Safe PIN → All-Clear, Duress PIN → DURESS_COERCION).
  /// - Client chỉ cleanup hardware (siren, strobe, audio) SAU KHI backend xác nhận.
  Future<bool> verifyPinAndCancelSos({
    required String enteredPin,
    String? reason,
  }) async {
    if (enteredPin.length != 4) {
      debugPrint('SosController: PIN phải đủ 4 chữ số');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Gọi backend verify PIN (Phase 7 - backend là nguồn xác thực duy nhất)
      final cancelUseCase = _ref.read(cancelSosUseCaseProvider);
      final result = await cancelUseCase(
        pinCode: enteredPin,
        reason: reason,
      );

      return await result.when(
        success: (_) async {
          // PIN đúng → backend đã cancel session và gửi notification phù hợp
          debugPrint(
              'SosController: Backend xác nhận PIN đúng, đang cleanup hardware...');

          // 2. Đợi upload queue flush (tối đa 2.5s)
          try {
            final dangerNotifier = _ref.read(dangerAudioProvider.notifier);
            await dangerNotifier.flushUploadQueue(
                timeout: const Duration(milliseconds: 2500));
          } catch (e) {
            debugPrint('SosController: Lỗi flush upload queue: $e');
          }

          // 3. Dừng hardware
          final audioPlayer = _ref.read(emergencyAudioPlayerProvider);
          final flashlight = _ref.read(flashlightControllerProvider);
          await audioPlayer.stopSiren();
          await flashlight.turnOff();
          try {
            final dangerNotifier = _ref.read(dangerAudioProvider.notifier);
            await dangerNotifier.stopMonitoring();
          } catch (e) {
            debugPrint('SosController: Lỗi dừng dangerAudio: $e');
          }

          // 4. Clear state
          state = state.copyWith(
            isLoading: false,
            clearActiveSession: true,
            isSirenPlaying: false,
            isStrobeActive: false,
            isAudioRecording: false,
          );
          return true;
        },
        error: (failure) {
          // PIN sai - KHÔNG clear session
          debugPrint('SosController: PIN sai - ${failure.message}');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
      );
    } catch (e) {
      // Network error hoặc exception khác
      debugPrint('SosController: Lỗi khi verify PIN: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi kết nối: ${e.toString()}',
      );
      return false;
    }
  }
}
