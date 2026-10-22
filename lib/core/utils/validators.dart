/// ============================================================================
/// FILE: lib/core/utils/validators.dart
/// MODULE: Core Utility - Validators
/// ROLE:
///   Quy chuẩn xác thực dữ liệu đầu vào:
///   - Số điện thoại di động Việt Nam (10 chữ số, đầu số 03, 05, 07, 08, 09, hỗ trợ +84).
///   - Telegram Chat ID (chuỗi số 6 - 14 ký tự).
///   - Email, Mật khẩu.
/// ============================================================================

abstract class AppValidators {
  /// Regex kiểm tra số điện thoại di động Việt Nam:
  /// - Bắt đầu bằng 0
  /// - Ký tự thứ hai là 3, 5, 7, 8, 9 (các mạng di động Viettel, Vinaphone, Mobifone, Vietnamobile, Wintel, Gmobile...)
  /// - Theo sau bởi đúng 8 chữ số (Tổng cộng đúng 10 chữ số)
  static final RegExp vnPhoneRegex = RegExp(r'^0[35789]\d{8}$');

  /// Regex kiểm tra Telegram Chat ID cá nhân / group:
  /// - Dãy số nguyên dương từ 6 đến 12 số (hoặc số âm với nhóm/kênh)
  static final RegExp telegramChatIdRegex = RegExp(r'^-?\d{6,14}$');

  /// Regex kiểm tra Email
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Chuẩn hóa số điện thoại:
  /// - Xóa sạch khoảng trắng, dấu gạch ngang, dấu chấm
  /// - Đổi tiền tố quốc tế +84 thành 0
  static String normalizePhone(String rawPhone) {
    return rawPhone
        .trim()
        .replaceAll(RegExp(r'[\s\-\.]'), '')
        .replaceFirst(RegExp(r'^\+84'), '0');
  }

  /// Kiểm tra số điện thoại di động Việt Nam hợp lệ (Bắt đầu bằng 0 và đủ 10 chữ số)
  static bool isValidVnPhone(String rawPhone) {
    final clean = normalizePhone(rawPhone);
    return vnPhoneRegex.hasMatch(clean);
  }

  /// Kiểm tra Telegram Chat ID hợp lệ (Chuỗi số nguyên)
  static bool isValidTelegramId(String? rawId) {
    if (rawId == null || rawId.trim().isEmpty) return true;
    return telegramChatIdRegex.hasMatch(rawId.trim());
  }

  /// Kiểm tra Email hợp lệ
  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email.trim());
  }
}

