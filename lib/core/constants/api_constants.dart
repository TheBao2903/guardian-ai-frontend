/// ============================================================================
/// FILE: lib/core/constants/api_constants.dart
/// MODULE: Core API Constants
/// ROLE:
///   Định nghĩa toàn bộ Base URL, Endpoints và Timeouts cho kết nối Backend.
///   Đồng bộ 100% với FastAPI routes tại backend/app/main.py.
/// ============================================================================

library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  /// Base URL API - BẮT BUỘC đọc từ file .env
  /// Không hardcoded IP, phải cấu hình qua biến môi trường
  static String get baseUrl {
    const overrideUrl = String.fromEnvironment('API_BASE_URL');
    final envUrl =
        overrideUrl.isNotEmpty ? overrideUrl : dotenv.env['API_BASE_URL'];
    if (envUrl == null || envUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL chưa được cấu hình trong file .env!\n'
        'Vui lòng tạo file .env với nội dung:\n'
        'API_BASE_URL=http://<IP_MAY_BACKEND>:8000/api/v1',
      );
    }
    return envUrl;
  }

  /// WebSocket URL - BẮT BUỘC đọc từ file .env
  static String get wsUrl {
    const overrideUrl = String.fromEnvironment('WS_BASE_URL');
    final envUrl =
        overrideUrl.isNotEmpty ? overrideUrl : dotenv.env['WS_BASE_URL'];
    if (envUrl == null || envUrl.isEmpty) {
      throw StateError(
        'WS_BASE_URL chưa được cấu hình trong file .env!\n'
        'Vui lòng tạo file .env với nội dung:\n'
        'WS_BASE_URL=ws://<IP_MAY_BACKEND>:8000/api/v1/realtime/ws',
      );
    }
    return envUrl;
  }

  /// Thời gian chờ kết nối (30 giây)
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Thời gian chờ nhận phản hồi từ đám mây (60 giây)
  static const Duration receiveTimeout = Duration(seconds: 60);

  // --- 1. AUTHENTICATION ---
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';

  // --- 2. EMERGENCY & SOS ---
  static const String emergencySos = '/emergency/sos';
  static const String emergencyCancel = '/emergency/cancel';
  static const String emergencyStatus = '/emergency/active';

  // --- 3. SAFETY CHECK TIMER ---
  static const String safetyCheckStart = '/safety-check/start';
  static const String safetyCheckCurrent = '/safety-check/current';
  static const String safetyCheckTemplates = '/safety-check/templates';
  static String safetyCheckConfirmSafe(String instanceId) =>
      '/safety-check/instances/$instanceId/confirm-safe';
  static String safetyCheckExtend(String instanceId) =>
      '/safety-check/instances/$instanceId/extend';
  static String safetyCheckCancel(String instanceId) =>
      '/safety-check/instances/$instanceId/cancel';
  static String safetyCheckCheckpoint(String instanceId) =>
      '/safety-check/instances/$instanceId/checkpoint-location';

  // --- 4. EMERGENCY CONTACTS ---
  static const String contactsList = '/contacts';
  static const String contactsAdd = '/contacts';
  static const String contactsDelete = '/contacts';
  static const String contactsTelegramLink = '/contacts/telegram-link';

  // --- 5. LOCATION CHECKPOINTS ---
  static const String locationCheckpoint = '/location/checkpoint';

  // --- 6. AI AUDIO DETECTION ---
  static const String detectionAnalyzeAudio = '/detection/analyze-audio';
}
