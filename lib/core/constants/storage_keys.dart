/// ============================================================================
/// FILE: lib/core/constants/storage_keys.dart
/// MODULE: Core Storage Keys
/// ROLE:
///   Định nghĩa hằng số các khóa lưu trữ an toàn trong SecureStorage / LocalStorage.
/// ============================================================================

abstract class StorageKeys {
  static const String accessToken = 'guardian_access_token';
  static const String refreshToken = 'guardian_refresh_token';
  static const String userId = 'guardian_user_id';
  static const String languageCode = 'guardian_language_code';
  static const String themeMode = 'guardian_theme_mode';
  static const String sosPinCode = 'guardian_sos_pin_code'; // Mã PIN 4 số cố định bảo vệ hủy SOS
  static const String duressPinCode = 'guardian_duress_pin_code'; // Mã PIN cưỡng bức (Duress PIN - mặc định 9999)
  static const String hasChangedPin = 'guardian_has_changed_pin'; // Cờ đánh dấu user đã từng đổi PIN (true = fallback '1234' bị vô hiệu)
  static const String hasChangedDuressPin = 'guardian_has_changed_duress_pin'; // Cờ đánh dấu user đã từng đổi Duress PIN (true = fallback '9999' bị vô hiệu)
}
