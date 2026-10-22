/// ============================================================================
/// FILE: lib/core/error/app_exception.dart
/// MODULE: Core Technical Exceptions
/// ROLE:
///   Định nghĩa các ngoại lệ kỹ thuật quăng ra từ DataSources, Network hoặc Device.
///   Data Layer sẽ bắt các AppException này để chuyển đổi (map) sang Failure.
/// ============================================================================

abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => '$runtimeType: $message (code: $statusCode)';
}

/// Lỗi mạng (Mất kết nối, Timeout, DNS không phản hồi)
class NetworkException extends AppException {
  const NetworkException([super.message = 'Không có kết nối mạng', super.statusCode]);
}

/// Lỗi phản hồi từ Server (500, 502, 503)
class ServerException extends AppException {
  const ServerException([super.message = 'Lỗi máy chủ', super.statusCode]);
}

/// Lỗi xác thực (401 Hết hạn token, 403 Bị cấm)
class AuthException extends AppException {
  const AuthException([super.message = 'Phiên đăng nhập hết hạn', super.statusCode = 401]);
}

/// Lỗi phần cứng thiết bị (GPS bị tắt, không cấp quyền mic/camera)
class DeviceException extends AppException {
  const DeviceException([super.message = 'Thiết bị không hỗ trợ hoặc chưa cấp quyền', super.statusCode]);
}

/// Lỗi dữ liệu không hợp lệ (Validation 422)
class ValidationException extends AppException {
  const ValidationException([super.message = 'Dữ liệu không hợp lệ', super.statusCode = 422]);
}

/// Lỗi xung đột dữ liệu (Conflict 409 - Email đã tồn tại, tài nguyên bị trùng lặp)
class ConflictException extends AppException {
  const ConflictException([super.message = 'Dữ liệu đã tồn tại trong hệ thống', super.statusCode = 409]);
}

