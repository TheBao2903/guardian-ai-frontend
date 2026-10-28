import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Device coordinates only: never substitute an IP lookup or a fixed city.
class LocationService {
  LocationService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const acquisitionTimeout = Duration(seconds: 6);
  static const _cacheReadTimeout = Duration(milliseconds: 300);
  static const _statusTimeout = Duration(seconds: 1);
  final DateTime Function() _now;
  Position? _cachedPosition;
  Future<Position?>? _inFlight;

  Future<bool> hasLocationPermission() async {
    try {
      final permission =
          await Geolocator.checkPermission().timeout(_statusTimeout);
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  Future<Position?> authorizeAndGetCurrentLocation() => getCurrentLocation();

  /// Reuse a fix at most 30 seconds old with <=100m accuracy. Concurrent
  /// callers share one acquisition, including the OS permission prompt.
  /// Permission prompts wait for the user's choice; sensor acquisition is bounded.
  Future<Position?> getCurrentLocation({bool highAccuracy = true}) {
    return _inFlight ??= _resolve(highAccuracy: highAccuracy)
        .whenComplete(() => _inFlight = null);
  }

  Future<Position?> _resolve({required bool highAccuracy}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()
          .timeout(_statusTimeout)) {
        _cachedPosition = null;
        return null;
      }
      var permission =
          await Geolocator.checkPermission().timeout(_statusTimeout);
      // On web requestPermission itself performs an unbounded location lookup,
      // then discards the coordinates. Let the bounded lookup prompt once.
      if (!kIsWeb && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // Safari may lack the Permissions API; getCurrentPosition prompts there.
      if ((!kIsWeb && permission == LocationPermission.denied) ||
          permission == LocationPermission.deniedForever ||
          (!kIsWeb && permission == LocationPermission.unableToDetermine)) {
        _cachedPosition = null;
        return null;
      }

      if (_usable(_cachedPosition, const Duration(seconds: 30), 100)) {
        return _cachedPosition;
      }
      Position? last;
      // The browser plugin does not implement getLastKnownPosition.
      if (!kIsWeb) {
        try {
          last = await Geolocator.getLastKnownPosition()
              .timeout(_cacheReadTimeout);
        } catch (_) {}
      }
      if (_usable(last, const Duration(seconds: 30), 100)) {
        return _cachedPosition = last;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy:
              highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
          timeLimit: acquisitionTimeout,
        ).timeout(acquisitionTimeout);
        if (_usable(position, const Duration(seconds: 30), double.infinity)) {
          return _cachedPosition = position;
        }
      } on PermissionDeniedException {
        _cachedPosition = null;
        return null;
      } on LocationServiceDisabledException {
        _cachedPosition = null;
        return null;
      } catch (error) {
        debugPrint('Location acquisition unavailable: ${error.runtimeType}');
      }

      // Keep the original timestamp/accuracy; never send an old or invented fix.
      final candidates = [last, _cachedPosition]
          .whereType<Position>()
          .where((p) => _usable(p, const Duration(minutes: 2), 1000))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return candidates.isEmpty ? null : (_cachedPosition = candidates.first);
    } catch (error) {
      debugPrint('Location access unavailable: ${error.runtimeType}');
      return null;
    }
  }

  bool _usable(Position? position, Duration maxAge, double maxAccuracy) {
    if (position == null) return false;
    final age = _now().difference(position.timestamp);
    return !age.isNegative &&
        age <= maxAge &&
        position.latitude.isFinite &&
        position.latitude.abs() <= 90 &&
        position.longitude.isFinite &&
        position.longitude.abs() <= 180 &&
        position.accuracy.isFinite &&
        position.accuracy >= 0 &&
        position.accuracy <= maxAccuracy;
  }

  static String formatGoogleMapsUrl(double latitude, double longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }

  static String formatGoogleMapsNavigationUrl(
      double latitude, double longitude) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }
}
