import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian_ai/core/device/location/location_service.dart';

import 'location_service_test.dart' show FakeLocationPlatform;

void main() {
  late GeolocatorPlatform original;
  late FakeLocationPlatform platform;
  final now = DateTime.utc(2026, 10, 28);
  final fix = Position(
    latitude: 21.03,
    longitude: 105.85,
    timestamp: now,
    accuracy: 15,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  setUp(() {
    original = GeolocatorPlatform.instance;
    platform = FakeLocationPlatform()..current = fix;
    GeolocatorPlatform.instance = platform;
  });
  tearDown(() => GeolocatorPlatform.instance = original);

  for (final permission in [
    LocationPermission.denied,
    LocationPermission.unableToDetermine,
  ]) {
    test('web $permission uses one bounded lookup to prompt and locate',
        () async {
      platform.permission = permission;
      final service = LocationService(now: () => now);
      expect(await service.authorizeAndGetCurrentLocation(), same(fix));
      expect(platform.prompts, 0);
      expect(platform.acquisitions, 1);
      expect(platform.settings!.timeLimit, LocationService.acquisitionTimeout);
      expect(await service.getCurrentLocation(), same(fix));
      expect(platform.acquisitions, 1);
    }, skip: !kIsWeb);
  }

  testWidgets('web prompt/location stall is bounded without IP fallbacks',
      (tester) async {
    platform.permission = LocationPermission.denied;
    platform.pending = Completer<Position>();
    final service = LocationService(now: () => now);
    var done = false;
    unawaited(service.getCurrentLocation().then((position) {
      expect(position, isNull);
      done = true;
    }));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(done, isTrue);
    expect(platform.prompts, 0);
    platform.pending!.complete(fix);
    await tester.pump();
  }, skip: !kIsWeb);
}
