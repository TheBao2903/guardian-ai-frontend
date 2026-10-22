import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/api_client.dart' show secureStorageProvider;
export '../../core/network/api_client.dart' show secureStorageProvider;

/// ============================================================================
/// FILE: lib/app/localization/locale_controller.dart
/// MODULE: Application Language & Locale State Management
/// ROLE:
///   1. Quản lý trạng thái Locale hiện tại của toàn bộ ứng dụng (Reactive State).
///   2. Đọc và lưu ngôn ngữ người dùng vào SecureStorage (Persistence).
///   3. Mặc định tiếng Việt nếu chưa có lựa chọn ngôn ngữ được lưu.
///   4. Cho phép đổi ngôn ngữ động tức thời mà KHÔNG cần restart app hay reset route.
/// ============================================================================

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return LocaleController(storage);
});

class LocaleController extends StateNotifier<Locale> {
  final SecureStorage _storage;
  int _selectionRevision = 0;
  Future<void> _pendingWrite = Future.value();

  static const Locale defaultLocale = Locale('vi');
  static const List<String> supportedLanguageCodes = ['vi', 'en'];

  LocaleController(this._storage) : super(defaultLocale) {
    loadSavedLocale();
  }

  /// Khôi phục lựa chọn đã lưu; không lấy ngôn ngữ từ thiết bị/trình duyệt.
  Future<void> loadSavedLocale() async {
    final revision = _selectionRevision;
    String? savedCode;
    try {
      savedCode = await _storage.read(StorageKeys.languageCode);
    } catch (_) {
      // A storage failure must not prevent selecting a language for this session.
    }
    if (!mounted || revision != _selectionRevision) return;
    if (savedCode != null && supportedLanguageCodes.contains(savedCode)) {
      state = Locale(savedCode);
      return;
    }

    state = defaultLocale;
  }

  /// Cập nhật ngôn ngữ mới, lưu vào storage và kích hoạt rebuild toàn app
  Future<void> setLocale(Locale newLocale) async {
    if (!mounted || !supportedLanguageCodes.contains(newLocale.languageCode))
      return;
    // Even choosing the currently visible default must supersede an old read.
    _selectionRevision++;
    state = Locale(newLocale.languageCode);
    // Serialize writes so a slow previous selection cannot overwrite the latest.
    final pending = _pendingWrite.catchError((_) {}).then((_) => _storage.write(
        key: StorageKeys.languageCode, value: newLocale.languageCode));
    _pendingWrite = pending;
    await pending;
  }

  /// Helper chuyển đổi giữa tiếng Việt và tiếng Anh nhanh
  Future<void> toggleLanguage() async {
    final nextCode = state.languageCode == 'vi' ? 'en' : 'vi';
    await setLocale(Locale(nextCode));
  }
}
