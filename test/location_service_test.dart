import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian_ai/core/device/location/location_service.dart';

class FakeLocationPlatform extends GeolocatorPlatform {
  bool enabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission requestedPermission = LocationPermission.whileInUse;
  Position? last;
  Position? current;
  Completer<Position>? pending;
  Completer<Position?>? pendingLast;
  Object? error;
  int acquisitions = 0;
  int prompts = 0;
  LocationSettings? settings;

  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async {
    prompts++;
    return permission = requestedPermission;
  }

  @override
  Future<Position?> getLastKnownPosition({bool forceLocationManager = false}) =>
      pendingLast?.future ?? Future.value(last);

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    acquisitions++;
    settings = locationSettings;
    if (error != null) return Future.error(error!);
    return pending?.future ?? Future.value(current!);
  }
}

void main() {
  final now = DateTime.utc(2026, 10, 28, 10);
  Position fix({int age = 0, double accuracy = 10, double latitude = 21.03}) =>
      Position(
        latitude: latitude,
        longitude: 105.85,
        timestamp: now.subtract(Duration(seconds: age)),
        accuracy: accuracy,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
  late GeolocatorPlatform original;
  late FakeLocationPlatform platform;
  late LocationService service;
  setUp(() {
    original = GeolocatorPlatform.instance;
    platform = FakeLocationPlatform()..current = fix();
    GeolocatorPlatform.instance = platform;
    service = LocationService(now: () => now);
  });
  tearDown(() => GeolocatorPlatform.instance = original);

  test('uses a recent accurate device fix without waiting for GPS', () async {
    platform.last = fix(age: 20);
    expect(await service.getCurrentLocation(), same(platform.last));
    expect(platform.acquisitions, 0);
  });

  test('shares permission and acquisition across simultaneous callers',
      () async {
    platform.permission = LocationPermission.denied;
    platform.pending = Completer<Position>();
    final first = service.getCurrentLocation();
    final second = service.authorizeAndGetCurrentLocation();
    expect(identical(first, second), isTrue);
    platform.pending!.complete(fix());
    expect(await first, isNotNull);
    expect(await second, isNotNull);
    expect(platform.prompts, 1);
    expect(platform.acquisitions, 1);
    expect(platform.settings!.timeLimit, LocationService.acquisitionTimeout);
  });

  test('reuses the in-memory fix on web-style cache misses', () async {
    final first = await service.getCurrentLocation();
    expect(await service.getCurrentLocation(), same(first));
    expect(platform.acquisitions, 1);
  });

  test('expired memory cache triggers another acquisition', () async {
    var clock = now;
    service = LocationService(now: () => clock);
    await service.getCurrentLocation();
    clock = clock.add(const Duration(seconds: 31));
    platform.current = fix(age: -31);
    expect(await service.getCurrentLocation(), same(platform.current));
    expect(platform.acquisitions, 2);
  });

  testWidgets('sensor stall returns within six seconds without a fake city',
      (tester) async {
    platform.pending = Completer<Position>();
    var finished = false;
    Position? result;
    unawaited(service.getCurrentLocation().then((value) {
      result = value;
      finished = true;
    }));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(finished, isTrue);
    expect(result, isNull);
    platform.pending!.complete(fix());
    await tester.pump();
    // A late plugin response must not populate the memory cache.
    await service.getCurrentLocation();
    expect(platform.acquisitions, 2);
  });

  testWidgets('a stalled last-known lookup does not block acquisition',
      (tester) async {
    platform.pendingLast = Completer<Position?>();
    Position? result;
    unawaited(service.getCurrentLocation().then((value) => result = value));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(result, same(platform.current));
    platform.pendingLast!.complete(null);
    await tester.pump();
  });

  test('uses a bounded-age real fallback after a GPS failure', () async {
    platform.last = fix(age: 90, accuracy: 250);
    platform.error = TimeoutException('No fix');
    final result = await service.getCurrentLocation();
    expect(result, same(platform.last));
    expect(result!.timestamp, platform.last!.timestamp);
    expect(result.accuracy, 250);
  });

  for (final invalid in [
    fix(age: 121),
    fix(age: -1),
    fix(accuracy: double.nan),
    fix(accuracy: -1),
    fix(accuracy: 1001),
    fix(latitude: 91),
  ]) {
    test('rejects stale/invalid fallback ${invalid.toString()}', () async {
      platform.last = invalid;
      platform.error = TimeoutException('No fix');
      expect(await service.getCurrentLocation(), isNull);
    });
  }

  test('refreshes coarse cache before returning a current fix', () async {
    platform.last = fix(accuracy: 500);
    expect(await service.getCurrentLocation(highAccuracy: false),
        same(platform.current));
    expect(platform.settings!.accuracy, LocationAccuracy.medium);
  });

  test('disabled services skip GPS and cached coordinates', () async {
    platform.enabled = false;
    platform.last = fix();
    expect(await service.getCurrentLocation(), isNull);
    expect(platform.acquisitions, 0);
    expect(platform.prompts, 0);
  });

  for (final permission in [
    LocationPermission.denied,
    LocationPermission.deniedForever,
  ]) {
    test('permission $permission never falls through to GPS/cache', () async {
      platform.permission = permission;
      platform.requestedPermission = LocationPermission.denied;
      platform.last = fix();
      expect(await service.getCurrentLocation(), isNull);
      expect(platform.acquisitions, 0);
    });
  }

  test('revoked permission prevents reuse of memory cache', () async {
    await service.getCurrentLocation();
    platform.permission = LocationPermission.deniedForever;
    expect(await service.getCurrentLocation(), isNull);
    expect(await service.hasLocationPermission(), isFalse);
  });

  test('permission revoked during acquisition does not return fallback',
      () async {
    platform.last = fix(age: 90);
    platform.error = const PermissionDeniedException('Revoked');
    expect(await service.getCurrentLocation(), isNull);
  });
}
