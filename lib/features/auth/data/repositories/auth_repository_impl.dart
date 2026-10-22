/// ============================================================================
/// FILE: lib/features/auth/data/repositories/auth_repository_impl.dart
/// MODULE: Auth - Data Repository Implementation
/// ROLE:
///   Triển khai AuthRepository, lưu trữ token an toàn và chịu lỗi mạng.
/// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(dataSource, storage);
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  UserEntity? _cachedUser;

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res =
          await _remoteDataSource.login(email: email, password: password);
      final token = (res['access_token'] ?? res['custom_token'] ?? res['token'])
          as String?;
      final refreshToken = res['refresh_token'] as String?;
      final userJson = res['user'] as Map<String, dynamic>?;

      if (token != null) {
        await _secureStorage.write(key: StorageKeys.accessToken, value: token);
      }
      if (refreshToken != null) {
        await _secureStorage.write(
            key: StorageKeys.refreshToken, value: refreshToken);
      }

      final entity = userJson != null
          ? UserModel.fromJson(userJson).toEntity()
          : UserEntity(
              uid: 'u_${DateTime.now().millisecondsSinceEpoch}',
              email: email,
              displayName: email.split('@').first);

      _cachedUser = entity;
      await _secureStorage.write(key: StorageKeys.userId, value: entity.uid);
      await _secureStorage.write(
          key: StorageKeys.sosPinCode, value: entity.sosPin);

      return Result.success(entity);
    } on AppException catch (e) {
      if (e is NetworkException) {
        return Result.error(ServerFailure(
            'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng hoặc địa chỉ IP backend.'));
      }
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(
          ServerFailure('Đăng nhập thất bại. Vui lòng thử lại.'));
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    try {
      final res = await _remoteDataSource.register(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
      );
      final token = (res['access_token'] ?? res['custom_token'] ?? res['token'])
          as String?;
      if (token != null) {
        await _secureStorage.write(key: StorageKeys.accessToken, value: token);
      }

      final userJson = res['user'] as Map<String, dynamic>?;
      final entity = userJson != null
          ? UserModel.fromJson(userJson).toEntity()
          : UserEntity(
              uid: 'u_${DateTime.now().millisecondsSinceEpoch}',
              email: email,
              displayName: displayName,
              phone: phone,
            );
      _cachedUser = entity;
      await _secureStorage.write(key: StorageKeys.userId, value: entity.uid);
      await _secureStorage.write(
          key: StorageKeys.sosPinCode, value: entity.sosPin);

      return Result.success(entity);
    } on AppException catch (e) {
      if (e is NetworkException) {
        return Result.error(ServerFailure(
            'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng hoặc địa chỉ IP backend.'));
      }
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure('Đăng ký thất bại. Vui lòng thử lại.'));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    final token = await _secureStorage.read(StorageKeys.accessToken);
    if (token == null || token.isEmpty || token == 'offline_session_token') {
      // Dọn dẹp token rác nếu có
      if (token == 'offline_session_token') {
        await _secureStorage.delete(StorageKeys.accessToken);
        _cachedUser = null;
      }
      return Result.success(null);
    }

    if (_cachedUser != null) {
      return Result.success(_cachedUser);
    }

    try {
      final model = await _remoteDataSource.getMe();
      final entity = model.toEntity();
      _cachedUser = entity;
      return Result.success(entity);
    } catch (_) {
      // Khi lỗi, trả về null để buộc đăng nhập lại
      return Result.success(null);
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    required String displayName,
    String? phone,
    String? telegramId,
  }) async {
    try {
      final model = await _remoteDataSource.updateProfile(
        displayName: displayName,
        phone: phone,
        telegramId: telegramId,
      );
      final entity = model.toEntity();
      _cachedUser = entity;
      return Result.success(entity);
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(
          ServerFailure('Không thể cập nhật hồ sơ: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool>> testTelegramNotification({
    required String telegramId,
    String? message,
  }) async {
    try {
      final res = await _remoteDataSource.testTelegram(
        telegramId: telegramId,
        message: message,
      );
      final success = res['success'] as bool? ?? false;
      final errorMsg = res['error_message'] as String?;
      if (!success && errorMsg != null) {
        return Result.error(ServerFailure(errorMsg));
      }
      return Result.success(success);
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(
          ServerFailure('Không thể kết nối bot Telegram: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> verifyPin(String pin, {bool duress = false}) async {
    if (!RegExp(r'^[0-9]{4}$').hasMatch(pin)) {
      return Result.error(
          const ValidationFailure('Mã PIN phải đủ đúng 4 chữ số'));
    }
    try {
      await _remoteDataSource.verifyPin(pin, duress: duress);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return Result.error(const NetworkFailure(
          'Không thể xác thực mã PIN. Kiểm tra kết nối và thử lại.'));
    }
  }

  @override
  Future<Result<void>> updateSosPin(String newPin) async {
    if (!RegExp(r'^[0-9]{4}$').hasMatch(newPin)) {
      return Result.failure(
        ValidationFailure('Mã PIN phải đủ đúng 4 chữ số'),
      );
    }
    try {
      // 1. Gọi backend để hash + lưu PIN (PLAN_PIN_VERIFICATION_OVERHAUL.md Phase 4)
      final response = await _remoteDataSource.updatePins(sosPin: newPin);
      if (response['sos_pin_set'] != true ||
          response['has_changed_sos_pin'] != true) {
        throw const ServerException('Máy chủ chưa xác nhận cập nhật mã PIN');
      }
      debugPrint('Backend xác nhận cập nhật SOS PIN: $response');

      // 2. Sync xuống local secure storage (cache để verify offline)
      await _secureStorage.write(key: StorageKeys.sosPinCode, value: newPin);
      await _secureStorage.write(key: StorageKeys.hasChangedPin, value: 'true');

      // 3. Update cached user nếu có
      if (_cachedUser != null) {
        _cachedUser = _cachedUser!.copyWith(sosPin: newPin);
      }
      return Result.success(null);
    } on NetworkException catch (e) {
      debugPrint('Lỗi mạng khi cập nhật SOS PIN: ${e.message}');
      return Result.failure(NetworkFailure(
        'Không thể kết nối tới server để cập nhật mã PIN. Vui lòng thử lại.',
      ));
    } catch (e) {
      debugPrint('Lỗi cập nhật SOS PIN: $e');
      return Result.failure(ValidationFailure(
        'Lỗi cập nhật mã PIN: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> updateDuressPin(String newDuressPin) async {
    if (!RegExp(r'^[0-9]{4}$').hasMatch(newDuressPin)) {
      return Result.failure(
        ValidationFailure('Mã PIN cưỡng bức phải đủ đúng 4 chữ số'),
      );
    }
    try {
      // 1. Gọi backend để hash + lưu Duress PIN
      final response =
          await _remoteDataSource.updatePins(duressPin: newDuressPin);
      if (response['duress_pin_set'] != true ||
          response['has_changed_duress_pin'] != true) {
        throw const ServerException(
            'Máy chủ chưa xác nhận cập nhật mã PIN cưỡng bức');
      }
      debugPrint('Backend xác nhận cập nhật Duress PIN: $response');

      // 2. Sync local
      await _secureStorage.write(
          key: StorageKeys.duressPinCode, value: newDuressPin);
      await _secureStorage.write(
          key: StorageKeys.hasChangedDuressPin, value: 'true');

      return Result.success(null);
    } on NetworkException catch (e) {
      debugPrint('Lỗi mạng khi cập nhật Duress PIN: ${e.message}');
      return Result.failure(NetworkFailure(
        'Không thể kết nối tới server để cập nhật mã PIN cưỡng bức. Vui lòng thử lại.',
      ));
    } catch (e) {
      debugPrint('Lỗi cập nhật Duress PIN: $e');
      return Result.failure(ValidationFailure(
        'Lỗi cập nhật mã PIN cưỡng bức: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<UserEntity>> updateMedicalProfile({
    required String bloodType,
    required String allergies,
    required String medicalNotes,
  }) async {
    try {
      await _remoteDataSource.updateMedicalProfile(
        bloodType: bloodType,
        allergies: allergies,
        medicalNotes: medicalNotes,
      );
      if (_cachedUser != null) {
        _cachedUser = _cachedUser!.copyWith(
          bloodType: bloodType,
          allergies: allergies,
          medicalNotes: medicalNotes,
        );
        return Result.success(_cachedUser!);
      }
      return Result.error(ServerFailure(
          'Không có thông tin người dùng. Vui lòng đăng nhập lại.'));
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message));
    } catch (e) {
      return Result.error(ServerFailure('Không thể cập nhật hồ sơ y tế: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    await _remoteDataSource.logout();
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
    await _secureStorage.delete(StorageKeys.userId);
    _cachedUser = null;
    return Result.success(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Result.success(null);
    } on AppException catch (e) {
      return Result.error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(
        e.toString().contains('Exception')
            ? 'Không thể đổi mật khẩu. Vui lòng kiểm tra lại mật khẩu hiện tại.'
            : e.toString(),
      ));
    }
  }

  @override
  Future<Result<String>> requestPasswordReset({required String email}) async {
    try {
      final res = await _remoteDataSource.requestPasswordReset(email: email);
      final resetLink = res['reset_link'] as String? ?? '';
      return Result.success(resetLink);
    } catch (e) {
      return Result.error(ServerFailure(
        'Không thể gửi yêu cầu khôi phục. Vui lòng kiểm tra email và thử lại.',
      ));
    }
  }

  @override
  Future<Result<UserEntity>> updateDeviceLocation({
    required String deviceName,
    required String platform,
    String? osVersion,
    required bool locationPermissionGranted,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? address,
  }) async {
    try {
      final model = await _remoteDataSource.updateDeviceLocation(
        deviceName: deviceName,
        platform: platform,
        osVersion: osVersion,
        locationPermissionGranted: locationPermissionGranted,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        address: address,
      );
      final entity = model.toEntity();
      _cachedUser = entity;
      return Result.success(entity);
    } catch (_) {
      // Khi lỗi, cập nhật in-memory nếu có cached user
      if (_cachedUser != null) {
        _cachedUser = _cachedUser!.copyWith(
          deviceInfo: {
            'device_name': deviceName,
            'platform': platform,
            'os_version': osVersion,
          },
          locationPermissionGranted: locationPermissionGranted,
          lastKnownLocation: latitude != null && longitude != null
              ? {
                  'latitude': latitude,
                  'longitude': longitude,
                  'accuracy': accuracy,
                  'address': address,
                }
              : null,
        );
        return Result.success(_cachedUser!);
      }
      return Result.error(ServerFailure(
          'Không thể cập nhật thông tin thiết bị. Vui lòng đăng nhập lại.'));
    }
  }
}
