import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

/// ============================================================================
/// FILE: lib/main.dart
/// MODULE: Application Root Entry Point
/// ROLE:
///   Khởi tạo binding, nạp cấu hình .env và chạy ứng dụng Guardian AI.
/// ============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nạp cấu hình biến môi trường từ .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Cho phép fallback nếu chạy môi trường test không có .env
  }

  runApp(
    const ProviderScope(
      child: GuardianApp(),
    ),
  );
}
