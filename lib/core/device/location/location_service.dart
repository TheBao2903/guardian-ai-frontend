import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// ============================================================================
/// FILE: lib/core/device/location/location_service.dart
/// MODULE: Core Device Location Capability
/// ROLE:
///   Giao tiếp với phần cứng GPS để lấy tọa độ hiện tại.
///   Hỗ trợ cơ chế Ủy quyền trước (Pre-Authorization) để khi bấm SOS
///   hệ thống tự lấy GPS ngầm tức thì mà không cần hỏi lại quyền.
///   Hỗ trợ cơ chế Fallback IP Geolocation khi chạy trên trình duyệt (như Safari iOS)
///   ở môi trường mạng nội bộ HTTP (Insecure Context) bị chặn navigator.geolocation.
/// ============================================================================

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  /// Kiểm tra xem ứng dụng đã được cấp quyền truy cập vị trí chưa
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (kIsWeb && permission == LocationPermission.unableToDetermine) {
        // Trên Safari Web, không query trước được quyền
        return true;
      }
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// Lấy vị trí dự phòng qua mạng IP khi GPS phần cứng bị chặn hoặc không khả dụng
  Future<Position?> getFallbackLocation() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      // 1. Thử ipwho.is (Hỗ trợ HTTPS & CORS không cần API key)
      try {
        final res = await dio.get<dynamic>('https://ipwho.is/');
        if (res.statusCode == 200 && res.data is Map) {
          final data = res.data as Map;
          if (data['success'] == true) {
            final lat = (data['latitude'] as num?)?.toDouble();
            final lng = (data['longitude'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              return Position(
                latitude: lat,
                longitude: lng,
                timestamp: DateTime.now(),
                accuracy: 1500.0,
                altitude: 0.0,
                altitudeAccuracy: 0.0,
                heading: 0.0,
                headingAccuracy: 0.0,
                speed: 0.0,
                speedAccuracy: 0.0,
              );
            }
          }
        }
      } catch (_) {}

      // 2. Thử ip-api.com
      try {
        final res = await dio.get<dynamic>('http://ip-api.com/json');
        if (res.statusCode == 200 && res.data is Map) {
          final data = res.data as Map;
          if (data['status'] == 'success') {
            final lat = (data['lat'] as num?)?.toDouble();
            final lng = (data['lon'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              return Position(
                latitude: lat,
                longitude: lng,
                timestamp: DateTime.now(),
                accuracy: 2000.0,
                altitude: 0.0,
                altitudeAccuracy: 0.0,
                heading: 0.0,
                headingAccuracy: 0.0,
                speed: 0.0,
                speedAccuracy: 0.0,
              );
            }
          }
        }
      } catch (_) {}

      // 3. Fallback mặc định theo trung tâm TP.HCM
      return Position(
        latitude: 10.776889,
        longitude: 106.700806,
        timestamp: DateTime.now(),
        accuracy: 3000.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    } catch (_) {
      return Position(
        latitude: 10.776889,
        longitude: 106.700806,
        timestamp: DateTime.now(),
        accuracy: 3000.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
  }

  /// Kích hoạt ủy quyền vị trí và lấy tọa độ GPS kiểm tra ban đầu
  Future<Position?> authorizeAndGetCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Trên Safari Web, checkPermission() trả về 'unableToDetermine' do thiếu W3C Permissions API.
      // Vì vậy miễn là không bị 'deniedForever', luôn gọi trực tiếp getCurrentPosition
      // để kích hoạt popup xin quyền vị trí phần cứng từ Safari iOS.
      if (permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        return pos;
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocationService: Ngoại lệ khi lấy GPS thật ($e). Thử kiểm tra vị trí gần nhất...');
      }
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return last;
      } catch (_) {}
    }

    // Tự động kích hoạt cơ chế dự phòng định vị qua IP nếu GPS bị từ chối
    return await getFallbackLocation();
  }

  /// Lấy tọa độ hiện tại cho SOS (Ưu tiên GPS thật, tự động fallback an toàn)
  Future<Position?> getCurrentLocation({bool highAccuracy = true}) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.deniedForever) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocationService: Ngoại lệ getCurrentLocation ($e). Thử lấy lastKnownPosition...');
      }
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return last;
      } catch (_) {}
    }

    return await getFallbackLocation();
  }

  /// Sinh đường dẫn xem vị trí trên Google Maps (Universal Deep Link)
  static String formatGoogleMapsUrl(double latitude, double longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }

  /// Sinh đường dẫn dẫn đường khẩn cấp trên Google Maps
  static String formatGoogleMapsNavigationUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }
}
