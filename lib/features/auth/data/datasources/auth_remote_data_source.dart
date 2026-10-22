/// ============================================================================
/// FILE: lib/features/auth/data/datasources/auth_remote_data_source.dart
/// MODULE: Auth - Remote Data Source
/// ROLE:
///   Giao tiếp trực tiếp với FastAPI backend phục vụ đăng nhập, đăng ký và lấy profile.
/// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Đăng nhập tài khoản
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  /// Đăng ký tài khoản
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'name': displayName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'accepted_terms': true,
        'accepted_privacy_policy': true,
        'accepted_audio_processing': true,
        'accepted_location_tracking': true,
        'accepted_medical_data_sharing': true,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  /// Lấy thông tin user hiện tại
  Future<UserModel> getMe() async {
    final response = await _apiClient.get('/users/me');
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Cập nhật thông tin cá nhân (Họ tên, SĐT, Telegram Chat ID)
  Future<UserModel> updateProfile({
    required String displayName,
    String? phone,
    String? telegramId,
  }) async {
    final response = await _apiClient.put(
      '/users/me',
      data: {
        'name': displayName,
        if (phone != null) 'phone': phone,
        if (telegramId != null) 'telegram_id': telegramId,
        'telegram_enabled': telegramId != null && telegramId.isNotEmpty,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Gửi thử thông báo tới Telegram Chat ID
  Future<Map<String, dynamic>> testTelegram({
    required String telegramId,
    String? message,
  }) async {
    final response = await _apiClient.post(
      '/notifications/test-telegram',
      data: {
        'telegram_id': telegramId,
        if (message != null) 'message': message,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  /// Đăng ký thông tin thiết bị và ủy quyền vị trí khẩn cấp
  Future<UserModel> updateDeviceLocation({
    required String deviceName,
    required String platform,
    String? osVersion,
    required bool locationPermissionGranted,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? address,
  }) async {
    final response = await _apiClient.put(
      '/users/me/device-location',
      data: {
        'device_name': deviceName,
        'platform': platform,
        if (osVersion != null) 'os_version': osVersion,
        'location_permission_granted': locationPermissionGranted,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (address != null) 'address': address,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {}
  }

  /// Đổi mật khẩu tài khoản đang đăng nhập
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  /// Yêu cầu reset mật khẩu - gửi link qua email
  Future<Map<String, dynamic>> requestPasswordReset(
      {required String email}) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  /// Cập nhật thông tin y tế khẩn cấp lên máy chủ
  Future<void> updateMedicalProfile({
    required String bloodType,
    required String allergies,
    required String medicalNotes,
  }) async {
    final allergiesList = allergies.isNotEmpty && allergies != 'Không có'
        ? allergies
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    await _apiClient.put(
      '/users/me/medical',
      data: {
        'blood_type': bloodType,
        'allergies': allergiesList,
        'medical_notes': medicalNotes,
        'privacy_level': 'EMERGENCY_SHARABLE',
      },
    );
  }

  /// Cập nhật mã PIN an toàn và/hoặc mã PIN cưỡng bức (PLAN_PIN_VERIFICATION_OVERHAUL.md - Phase 4).
  ///
  /// Backend sẽ:
  /// 1. Hash PIN bằng bcrypt (rounds=10, ~100ms).
  /// 2. Lưu vào Firestore user doc (`sos_pin_hash`, `duress_pin_hash`).
  /// 3. Set `has_changed_*` flag để vô hiệu hóa fallback '1234'/'9999'.
  ///
  /// Trả về metadata về PIN đã set (KHÔNG trả về PIN thật).
  Future<void> verifyPin(String pin, {bool duress = false}) async {
    final response =
        await _apiClient.post<dynamic>('/users/me/pins/verify', data: {
      'pin_code': pin,
      'duress': duress,
    });
    final body = response.data;
    if (body is! Map ||
        body['data'] is! Map ||
        body['data']['verified'] != true) {
      throw const ValidationException('Mã PIN không chính xác');
    }
  }

  Future<Map<String, dynamic>> updatePins({
    String? sosPin,
    String? duressPin,
  }) async {
    if (sosPin == null && duressPin == null) {
      throw ArgumentError('Cần cung cấp ít nhất sosPin hoặc duressPin');
    }
    final response = await _apiClient.put(
      '/users/me/pins',
      data: {
        if (sosPin != null) 'sos_pin': sosPin,
        if (duressPin != null) 'duress_pin': duressPin,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }
}
