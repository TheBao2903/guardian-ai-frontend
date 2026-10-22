import 'failure.dart';

/// ============================================================================
/// FILE: lib/core/error/result.dart
/// MODULE: Core Result Monad / Either Pattern
/// ROLE:
///   Đại diện cho kết quả của một hành động nghiệp vụ trong Clean Architecture:
///   - Success(data): Thành công, chứa dữ liệu T.
///   - Error(failure): Thất bại, chứa Failure.
///   Giúp xử lý lỗi rõ ràng, type-safe, không dùng try-catch ở tầng Presentation.
/// ============================================================================

abstract class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Failure failure) = Error<T>;
  factory Result.error(Failure failure) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  R fold<R>(R Function(Failure failure) onError, R Function(T data) onSuccess) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onError((this as Error<T>).failure);
    }
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return error((this as Error<T>).failure);
    }
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
