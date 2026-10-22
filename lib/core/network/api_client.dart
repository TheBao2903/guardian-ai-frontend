import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../error/app_exception.dart';
import '../storage/secure_storage.dart';
import 'api_interceptor.dart';

/// ============================================================================
/// FILE: lib/core/network/api_client.dart
/// MODULE: Core HTTP Network Client
/// ROLE:
///   Bao bọc Dio instance chuẩn hóa, quản lý timeout, cấu hình interceptor
///   và bắt lỗi chuyển đổi sang AppException.
/// ============================================================================

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage: storage);
});

class ApiClient {
  late final Dio _dio;

  ApiClient({required SecureStorage storage, Dio? customDio}) {
    _dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      ApiInterceptor(dio: _dio, storage: storage),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException('Kết nối máy chủ quá hạn hoặc mất mạng');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String message = 'Đã xảy ra lỗi máy chủ';

        if (responseData is Map) {
          if (responseData['error'] is Map && responseData['error']['message'] != null) {
            message = responseData['error']['message'].toString();
          } else if (responseData['message'] != null) {
            message = responseData['message'].toString();
          } else if (responseData['detail'] != null) {
            final detail = responseData['detail'];
            if (detail is List && detail.isNotEmpty && detail.first is Map && detail.first['msg'] != null) {
              message = detail.first['msg'].toString();
            } else {
              message = detail.toString();
            }
          }
        } else if (responseData is String && responseData.isNotEmpty) {
          message = responseData;
        }

        if (statusCode == 401) {
          return AuthException(message, statusCode);
        } else if (statusCode == 409) {
          return ConflictException(message, statusCode);
        } else if (statusCode == 422) {
          return ValidationException(message, statusCode);
        } else {
          return ServerException(message, statusCode);
        }

      case DioExceptionType.cancel:
        return const ServerException('Yêu cầu đã bị hủy');

      default:
        return ServerException(error.message ?? 'Lỗi không xác định');
    }
  }
}
