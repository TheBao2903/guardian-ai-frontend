import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';

/// ============================================================================
/// FILE: lib/core/network/api_interceptor.dart
/// MODULE: Network Auth & Auto-Refresh Token Interceptor
/// ROLE:
///   1. Tự động chèn Bearer Token vào Header của mọi HTTP Request.
///   2. Bắt lỗi 401 do TOKEN_EXPIRED:
///      - Âm thầm gọi /auth/refresh trong nền bằng Refresh Token từ SecureStorage.
///      - Lưu Access Token mới và Retry request gốc.
///      - Người dùng sử dụng app liên tục lâu dài mà KHÔNG bị văng ra đăng nhập lại.
/// ============================================================================

class ApiInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final SecureStorage _storage;
  bool _isRefreshing = false;

  ApiInterceptor({
    required Dio dio,
    required SecureStorage storage,
  })  : _dio = dio,
        _storage = storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Không đính kèm token cho các endpoint public
    final isPublic = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh');

    if (!isPublic) {
      final token = await _storage.read(StorageKeys.accessToken);
      if (token != null && token.isNotEmpty && token != 'offline_session_token') {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Nếu gặp 401 và không phải đang refresh hoặc gọi endpoint auth
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      final isAuthPath = err.requestOptions.path.contains('/auth/');
      if (!isAuthPath) {
        final refreshToken = await _storage.read(StorageKeys.refreshToken);

        if (refreshToken != null && refreshToken.isNotEmpty) {
          _isRefreshing = true;

          try {
            // Sử dụng một instance Dio độc lập để tránh vòng lặp interceptor
            final refreshDio = Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
              ),
            );

            final response = await refreshDio.post(
              ApiConstants.refreshToken,
              data: {'refresh_token': refreshToken},
            );

            if (response.statusCode == 200 && response.data != null) {
              final newAccessToken = response.data['access_token'] as String?;
              final newRefreshToken = response.data['refresh_token'] as String?;

              if (newAccessToken != null) {
                await _storage.write(
                  key: StorageKeys.accessToken,
                  value: newAccessToken,
                );

                if (newRefreshToken != null) {
                  await _storage.write(
                    key: StorageKeys.refreshToken,
                    value: newRefreshToken,
                  );
                }

                // Cập nhật header cho request gốc và retry
                final requestOptions = err.requestOptions;
                requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

                final clonedResponse = await _dio.fetch(requestOptions);
                _isRefreshing = false;
                return handler.resolve(clonedResponse);
              }
            }
          } catch (_) {
            // Refresh thất bại (Refresh token hết hạn hoàn toàn), xóa session
            await _storage.delete(StorageKeys.accessToken);
            await _storage.delete(StorageKeys.refreshToken);
          } finally {
            _isRefreshing = false;
          }
        }
      }
    }

    return handler.next(err);
  }
}
