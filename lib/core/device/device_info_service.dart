import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================================
/// FILE: lib/core/device/device_info_service.dart
/// MODULE: Core Device Information Capability
/// ROLE:
///   Nhận diện thông tin thiết bị đang sử dụng (Model, Hệ điều hành, Nền tảng)
///   phục vụ tính năng Đăng ký Thiết bị Tin cậy và gửi kèm trong Cảnh báo SOS.
///   Hỗ trợ đa nền tảng: iOS, Android, Web (Safari iPhone, Chrome Windows), Desktop.
/// ============================================================================

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService();
});

class DeviceSummary {
  final String deviceName;
  final String platform;
  final String osVersion;

  const DeviceSummary({
    required this.deviceName,
    required this.platform,
    required this.osVersion,
  });

  @override
  String toString() => '$deviceName ($platform $osVersion)';
}

class DeviceInfoService {
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  /// Lấy tóm tắt thông tin thiết bị hiện tại
  Future<DeviceSummary> getDeviceSummary() async {
    try {
      if (kIsWeb) {
        final webInfo = await _plugin.webBrowserInfo;
        final ua = webInfo.userAgent ?? '';
        String deviceName = 'Trình duyệt Web';
        String platform = 'Web';
        String osVersion = webInfo.browserName.name;

        if (ua.contains('iPhone')) {
          deviceName = 'Apple iPhone';
          platform = 'iOS (Web)';
          final match = RegExp(r'OS (\d+_\d+)').firstMatch(ua);
          if (match != null) {
            osVersion = 'iOS ${match.group(1)?.replaceAll('_', '.')}';
          }
        } else if (ua.contains('iPad')) {
          deviceName = 'Apple iPad';
          platform = 'iPadOS (Web)';
        } else if (ua.contains('Android')) {
          deviceName = 'Thiết bị Android';
          platform = 'Android (Web)';
        } else if (ua.contains('Windows')) {
          deviceName = 'Máy tính Windows';
          platform = 'Windows (Web)';
        } else if (ua.contains('Macintosh')) {
          deviceName = 'Máy tính Apple Mac';
          platform = 'macOS (Web)';
        }

        return DeviceSummary(
          deviceName: deviceName,
          platform: platform,
          osVersion: osVersion,
        );
      }

      if (Platform.isIOS) {
        final ios = await _plugin.iosInfo;
        return DeviceSummary(
          deviceName: ios.name.isNotEmpty ? ios.name : (ios.model.isNotEmpty ? ios.model : 'Apple iPhone'),
          platform: 'iOS',
          osVersion: '${ios.systemName} ${ios.systemVersion}',
        );
      }

      if (Platform.isAndroid) {
        final android = await _plugin.androidInfo;
        return DeviceSummary(
          deviceName: '${android.manufacturer} ${android.model}'.trim(),
          platform: 'Android',
          osVersion: 'Android ${android.version.release}',
        );
      }

      if (Platform.isWindows) {
        final win = await _plugin.windowsInfo;
        return DeviceSummary(
          deviceName: win.computerName.isNotEmpty ? win.computerName : 'Windows PC',
          platform: 'Windows',
          osVersion: win.productName,
        );
      }

      return const DeviceSummary(
        deviceName: 'Thiết bị Guardian AI',
        platform: 'Unknown',
        osVersion: '1.0',
      );
    } catch (_) {
      return const DeviceSummary(
        deviceName: 'Thiết bị người dùng',
        platform: 'Guardian Device',
        osVersion: '1.0',
      );
    }
  }
}
