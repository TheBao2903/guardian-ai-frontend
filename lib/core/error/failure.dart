import 'package:flutter/foundation.dart';

/// ============================================================================
/// FILE: lib/core/error/failure.dart
/// MODULE: Core Domain Failures
/// ROLE:
///   Định nghĩa các đối tượng Failure bất biến mà Repository trả về cho UseCases
///   và Presentation Layer. Tuyệt đối không quăng raw Exception lên UI.
/// ============================================================================

@immutable
abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thất bại do lỗi kết nối mạng
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Mất kết nối mạng', super.code]);
}

/// Thất bại do máy chủ trả về lỗi
class ServerFailure extends Failure {
  const ServerFailure(String message, {int? statusCode, int? code})
      : super(message, statusCode ?? code);
}

/// Thất bại do phiên xác thực hết hạn hoặc không hợp lệ
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Phiên làm việc hết hạn', super.code]);
}

/// Thất bại do quyền hoặc phần cứng thiết bị (GPS, Flashlight, Audio)
class DeviceFailure extends Failure {
  const DeviceFailure([super.message = 'Lỗi thiết bị hoặc chưa cấp quyền', super.code]);
}

/// Thất bại do dữ liệu đầu vào không hợp lệ
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Thông tin không hợp lệ', super.code]);
}
