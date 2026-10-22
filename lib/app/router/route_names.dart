/// ============================================================================
/// FILE: lib/app/router/route_names.dart
/// MODULE: Application Route Names & Paths
/// ROLE:
///   Định nghĩa toàn bộ tên và đường dẫn Route trong ứng dụng dạng hằng số,
///   triệt tiêu hoàn toàn magic strings theo quy định của ARCHITECTURE.md.
/// ============================================================================

library;

abstract class RouteNames {
  static const String sosConfirmation = '/sos-confirmation';
  // --- 4 TABS CHÍNH CỦA SHELL ---
  static const String home = '/home';
  static const String safetyCheck = '/safety-check';
  static const String contacts = '/contacts';
  static const String profile = '/profile';

  // --- FULLSCREEN SCREENS ---
  static const String activeSos = '/active-sos';
  static const String login = '/login';
  static const String register = '/register';
  static const String medicalProfile = '/medical-profile';
  static const String settings = '/settings';
}
