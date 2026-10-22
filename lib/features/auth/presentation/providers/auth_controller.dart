/// ============================================================================
/// FILE: lib/features/auth/presentation/providers/auth_controller.dart
/// MODULE: Auth - Presentation Controller
/// ROLE:
///   StateNotifier điều phối phiên đăng nhập, đăng xuất và đồng bộ trạng thái tài khoản.
/// ============================================================================

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/device/audio/danger_audio_providers.dart';

import '../../../contacts/presentation/providers/contacts_controller.dart';
import '../../../sos/presentation/providers/sos_controller.dart';
import '../../../safety_check/presentation/providers/safety_check_controller.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo, ref);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo, this._ref) : super(const AuthState()) {
    checkAuthStatus();
  }

  final AuthRepository _repo;
  final Ref _ref;

  /// Kích hoạt tải dữ liệu liên quan khi đã xác thực
  void _syncUserData() {
    _ref.read(dangerAudioProvider.notifier).resumeAlerts();
    _ref.read(contactsControllerProvider.notifier).loadContacts();
    _ref.read(safetyCheckControllerProvider.notifier).init();
  }

  /// Kiểm tra xem thiết bị đã có token phiên trước chưa
  Future<void> checkAuthStatus() async {
    final result = await _repo.getCurrentUser();
    result.when(
      success: (user) {
        state = state.copyWith(
          isInitialized: true,
          user: user,
        );
        if (user != null) {
          _syncUserData();
        }
      },
      error: (_) {
        state = state.copyWith(
          isInitialized: true,
          clearUser: true,
        );
      },
    );
  }

  /// Đăng nhập bằng Email và Password
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repo.login(email: email, password: password);

    return result.when(
      success: (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
        );
        _syncUserData();
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Đăng ký tài khoản mới
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repo.register(
      email: email,
      password: password,
      displayName: displayName,
      phone: phone,
    );

    return result.when(
      success: (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
        );
        _syncUserData();
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Cập nhật thông tin cá nhân (Họ tên, SĐT, Telegram Chat ID)
  Future<bool> updateProfile({
    required String displayName,
    String? phone,
    String? telegramId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repo.updateProfile(
      displayName: displayName,
      phone: phone,
      telegramId: telegramId,
    );
    return res.when(
      success: (updated) {
        state = state.copyWith(isLoading: false, user: updated);
        return true;
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  /// Gửi thử thông báo tới Telegram Chat ID
  Future<({bool success, String message})> testTelegramNotification({
    required String telegramId,
    String? message,
  }) async {
    final res = await _repo.testTelegramNotification(
      telegramId: telegramId,
      message: message,
    );
    return res.when(
      success: (ok) => (
        success: ok,
        message: ok
            ? 'Đã nhận tin nhắn'
            : 'Bot không thể gửi tin nhắn tới Chat ID này',
      ),
      error: (f) => (
        success: false,
        message: f.message,
      ),
    );
  }

  /// Cập nhật mã PIN 4 số hủy SOS (PLAN_PIN_VERIFICATION_OVERHAUL.md - Phase 4)
  /// Gọi backend `PUT /users/me/pins` để hash + lưu. Sau khi thành công,
  /// backend sẽ vô hiệu hóa fallback '1234' vĩnh viễn.
  Future<bool> verifyPin(String pin, {bool duress = false}) async {
    final result = await _repo.verifyPin(pin, duress: duress);
    return result.when(
      success: (_) {
        state = state.copyWith(errorMessage: null);
        return true;
      },
      error: (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> updateSosPin(String newPin) async {
    if (newPin.length != 4) {
      state = state.copyWith(errorMessage: 'Mã PIN phải đủ đúng 4 chữ số');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repo.updateSosPin(newPin);
    return res.when(
      success: (_) {
        if (state.user != null) {
          state = state.copyWith(
            user: state.user!.copyWith(sosPin: newPin),
            isLoading: false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
        return true;
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  /// Cập nhật mã PIN cưỡng bức (Duress PIN) - khi nhập sẽ trigger DURESS_COERCION alert.
  /// Gọi backend `PUT /users/me/pins` với duress_pin. Sau khi thành công,
  /// backend sẽ vô hiệu hóa fallback '9999' vĩnh viễn.
  Future<bool> updateDuressPin(String newDuressPin) async {
    if (newDuressPin.length != 4) {
      state = state.copyWith(
          errorMessage: 'Mã PIN cưỡng bức phải đủ đúng 4 chữ số');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repo.updateDuressPin(newDuressPin);
    return res.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  /// Cập nhật hồ sơ y tế khẩn cấp
  Future<bool> updateMedicalProfile({
    required String bloodType,
    required String allergies,
    required String medicalNotes,
  }) async {
    final res = await _repo.updateMedicalProfile(
      bloodType: bloodType,
      allergies: allergies,
      medicalNotes: medicalNotes,
    );
    return res.when(
      success: (updated) {
        state = state.copyWith(user: updated, errorMessage: null);
        return true;
      },
      error: (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
    );
  }

  /// Cập nhật thông tin thiết bị và ủy quyền vị trí khẩn cấp
  Future<bool> updateDeviceLocation({
    required String deviceName,
    required String platform,
    String? osVersion,
    required bool locationPermissionGranted,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? address,
  }) async {
    final res = await _repo.updateDeviceLocation(
      deviceName: deviceName,
      platform: platform,
      osVersion: osVersion,
      locationPermissionGranted: locationPermissionGranted,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      address: address,
    );
    return res.when(
      success: (updated) {
        state = state.copyWith(user: updated);
        return true;
      },
      error: (_) => false,
    );
  }

  /// Đăng xuất khỏi thiết bị
  Future<void> logout() async {
    await _ref.read(dangerAudioProvider.notifier).endLocalSession();
    await _repo.logout();
    _ref.invalidate(sosControllerProvider);
    _ref.invalidate(safetyCheckControllerProvider);
    state = state.copyWith(clearUser: true);
  }

  /// Đổi mật khẩu - Yêu cầu xác thực mật khẩu cũ trước khi đổi
  /// [currentPassword] - Mật khẩu hiện tại dùng để xác thực (gọi login để verify)
  /// [newPassword] - Mật khẩu mới (min 6 ký tự, có chữ + số)
  Future<({bool success, String message})> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Validate cường độ mật khẩu mới
    if (newPassword.length < 6) {
      return (success: false, message: 'Mật khẩu mới phải có ít nhất 6 ký tự');
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(newPassword);
    final hasNumber = RegExp(r'[0-9]').hasMatch(newPassword);
    if (!hasLetter || !hasNumber) {
      return (
        success: false,
        message: 'Mật khẩu mới phải có cả chữ cái và chữ số'
      );
    }
    if (newPassword == currentPassword) {
      return (
        success: false,
        message: 'Mật khẩu mới phải khác mật khẩu hiện tại'
      );
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    // Gửi yêu cầu đổi mật khẩu kèm mật khẩu hiện tại tới máy chủ để xác thực bảo mật
    final res = await _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return res.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        return (success: true, message: 'Đổi mật khẩu thành công');
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return (success: false, message: failure.message);
      },
    );
  }

  /// Yêu cầu gửi link reset mật khẩu qua email (dùng khi quên mật khẩu)
  Future<({bool success, String message})> requestPasswordReset({
    required String email,
  }) async {
    final res = await _repo.requestPasswordReset(email: email);
    return res.when(
      success: (resetLink) => (
        success: true,
        message:
            'Đã gửi email khôi phục mật khẩu tới $email. Vui lòng kiểm tra hộp thư.',
      ),
      error: (failure) => (
        success: false,
        message: failure.message,
      ),
    );
  }
}
