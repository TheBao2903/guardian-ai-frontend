/// ============================================================================
/// FILE: lib/features/auth/domain/repositories/auth_repository.dart
/// MODULE: Auth - Domain Repository Interface
/// ROLE:
///   Quy định hợp đồng đăng nhập, đăng ký, đăng xuất và cập nhật hồ sơ người dùng.
/// ============================================================================

import '../../../../core/error/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Đăng nhập tài khoản bằng Email & Mật khẩu
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới kèm cam kết bảo mật Nghị định 13
  Future<Result<UserEntity>> register({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  });

  /// Lấy thông tin user hiện tại từ token đã lưu
  Future<Result<UserEntity?>> getCurrentUser();

  /// Cập nhật thông tin cá nhân (Họ tên, SĐT, Telegram ID)
  Future<Result<UserEntity>> updateProfile({
    required String displayName,
    String? phone,
    String? telegramId,
  });

  /// Đổi mã PIN 4 số hủy SOS (PLAN_PIN_VERIFICATION_OVERHAUL.md Phase 4)
  /// Gọi backend `PUT /users/me/pins` để hash + lưu, sync local cache.
  Future<Result<void>> updateSosPin(String newPin);

  Future<Result<void>> verifyPin(String pin, {bool duress = false});

  /// Đổi mã PIN cưỡng bức (Duress PIN) - khi nhập sẽ trigger DURESS_COERCION alert.
  /// Gọi backend `PUT /users/me/pins` với duress_pin.
  Future<Result<void>> updateDuressPin(String newDuressPin);

  /// Cập nhật hồ sơ y tế khẩn cấp
  Future<Result<UserEntity>> updateMedicalProfile({
    required String bloodType,
    required String allergies,
    required String medicalNotes,
  });

  /// Gửi tin nhắn kiểm tra tới Telegram Chat ID
  Future<Result<bool>> testTelegramNotification({
    required String telegramId,
    String? message,
  });

  /// Đăng xuất khỏi thiết bị
  Future<Result<void>> logout();

  /// Đổi mật khẩu tài khoản (yêu cầu đã đăng nhập)
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Yêu cầu gửi link reset mật khẩu qua email (dùng khi quên mật khẩu)
  Future<Result<String>> requestPasswordReset({
    required String email,
  });

  /// Đăng ký thông tin thiết bị và ủy quyền vị trí khẩn cấp
  Future<Result<UserEntity>> updateDeviceLocation({
    required String deviceName,
    required String platform,
    String? osVersion,
    required bool locationPermissionGranted,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? address,
  });
}
