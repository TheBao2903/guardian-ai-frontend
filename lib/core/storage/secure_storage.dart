import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================================
/// FILE: lib/core/storage/secure_storage.dart
/// MODULE: Core Secure Storage Service
/// ROLE:
///   Lớp bao bọc (Wrapper) kết hợp đa tầng:
///   1. FlutterSecureStorage (iOS Keychain / Android KeyStore).
///   2. SharedPreferences (Web localStorage chuẩn W3C, không bị crash bởi WebCrypto trên HTTP LAN).
///   3. In-memory Cache (bảo toàn token trong suốt phiên làm việc).
/// ============================================================================

class SecureStorage {
  final FlutterSecureStorage _storage;
  static final Map<String, String> _memoryCache = {};

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<String?> read(String key) async {
    // 1. Kiểm tra cache trong RAM
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }

    // 2. Thử đọc từ FlutterSecureStorage
    try {
      final val = await _storage.read(key: key);
      if (val != null && val.isNotEmpty) {
        _memoryCache[key] = val;
        return val;
      }
    } catch (_) {}

    // 3. Fallback đọc từ SharedPreferences (rất quan trọng trên Web HTTP khi WebCrypto bị chặn)
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString('sec_$key');
      if (val != null && val.isNotEmpty) {
        _memoryCache[key] = val;
        return val;
      }
    } catch (_) {}

    return null;
  }

  Future<void> write({required String key, required String value}) async {
    _memoryCache[key] = value;

    // 1. Ghi vào SharedPreferences trước để đảm bảo Web luôn lưu được
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sec_$key', value);
    } catch (_) {}

    // 2. Ghi thêm vào FlutterSecureStorage (nếu nền tảng hỗ trợ)
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<void> delete(String key) async {
    _memoryCache.remove(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sec_$key');
    } catch (_) {}

    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    _memoryCache.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('sec_'));
      for (final k in keys) {
        await prefs.remove(k);
      }
    } catch (_) {}

    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
