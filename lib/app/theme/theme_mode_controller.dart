/// ============================================================================
/// FILE: lib/app/theme/theme_mode_controller.dart
/// MODULE: Theme Mode State Controller
/// ROLE:
///   1. Quản lý trạng thái giao diện: Sáng (Light) và Tối (Dark). Mặc định là Sáng (Light).
///   2. Đọc và lưu tùy chọn vào SecureStorage để duy trì qua các phiên làm việc.
///   3. Đồng bộ với MaterialApp.router qua themeModeProvider.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ThemeModeController(storage);
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  // Mặc định luôn là ThemeMode.light
  ThemeModeController(this._storage) : super(ThemeMode.light) {
    loadSavedThemeMode();
  }

  final SecureStorage _storage;

  /// Đọc theme mode đã lưu từ storage (chỉ Sáng hoặc Tối, mặc định Sáng)
  Future<void> loadSavedThemeMode() async {
    final saved = await _storage.read(StorageKeys.themeMode);
    if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  /// Thiết lập theme mode và lưu lại
  Future<void> setThemeMode(ThemeMode mode) async {
    final targetMode = mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
    if (state == targetMode) return;
    state = targetMode;
    await _storage.write(
      key: StorageKeys.themeMode,
      value: targetMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  /// Chuyển đổi qua lại giữa Sáng và Tối
  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }
}
