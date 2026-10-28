import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian_ai/core/device/audio/danger_audio_manager.dart';
import 'package:guardian_ai/core/device/audio/danger_audio_providers.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_analysis_transport.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_monitoring_status.dart';
import 'package:guardian_ai/core/device/audio/detection/yamnet_classifier.dart';
import 'package:guardian_ai/core/device/audio/recording/audio_recorder_service.dart';
import 'package:guardian_ai/core/device/location/location_service.dart';
import 'package:guardian_ai/core/network/api_client.dart';
import 'package:guardian_ai/core/storage/secure_storage.dart';
import 'audio_pipeline_resilience_test.dart'
    show ControlledTransport, acceptedAlert;

class NoTokenStorage extends SecureStorage {
  @override
  Future<String?> read(String key) async => null;
}

class NoLocation extends LocationService {
  @override
  Future<Position?> getCurrentLocation({bool highAccuracy = true}) async =>
      null;
}

class CurrentAlertApi extends ApiClient {
  CurrentAlertApi()
      : super(
            storage: NoTokenStorage(),
            customDio: Dio(BaseOptions(baseUrl: 'http://localhost/api/v1')));
  @override
  Future<Response<T>> get<T>(String path,
          {Map<String, dynamic>? queryParameters, Options? options}) async =>
      Response<T>(
          requestOptions: RequestOptions(path: path),
          data: {'data': null} as T);
}

class StreamRecorder implements AudioRecorderService {
  @override
  void Function(Uint8List)? onAudioChunk;
  @override
  bool isRecording = false;
  @override
  String? get lastError => null;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> start() async {
    isRecording = true;
    return true;
  }

  @override
  Future<void> stop() async {
    isRecording = false;
  }

  @override
  Future<void> dispose() => stop();
  void emit() => onAudioChunk?.call(Uint8List(38400)..[0] = 1);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class LocalScreamClassifier implements AudioClassifier {
  int classified = 0;
  bool recoverOnInitialize = false;
  Future<void>? initializingWork;
  @override
  bool isInitialized = true;
  bool failNext = false;
  @override
  AudioClassifierStatus get status =>
      isInitialized ? AudioClassifierStatus.ready : AudioClassifierStatus.error;
  @override
  Future<void> initialize() async {
    if (initializingWork != null) await initializingWork;
    if (recoverOnInitialize) {
      isInitialized = true;
      failNext = false;
    }
  }

  @override
  Future<List<OnDeviceClassificationResult>> classify(List<int> bytes) async {
    classified++;
    if (failNext) {
      isInitialized = false;
      return [];
    }
    return [
      const OnDeviceClassificationResult(
          eventType: DangerEventType.scream,
          labelName: 'Screaming',
          confidence: .8,
          classIndex: 11)
    ];
  }

  @override
  void dispose() {}
}

void main() {
  ProviderContainer setup(StreamRecorder recorder,
          LocalScreamClassifier classifier, ControlledTransport transport,
          {DateTime Function()? clock}) =>
      ProviderContainer(overrides: [
        dangerAudioApiClientProvider.overrideWithValue(CurrentAlertApi()),
        dangerAudioRecorderProvider.overrideWithValue(recorder),
        audioClassifierProvider.overrideWithValue(classifier),
        audioAnalysisTransportProvider.overrideWithValue(transport),
        locationServiceProvider.overrideWithValue(NoLocation()),
        secureStorageProvider.overrideWithValue(NoTokenStorage()),
        if (clock != null)
          audioMonitoringClockProvider.overrideWithValue(clock),
      ]);

  testWidgets('slow alert request never blocks subsequent local recognition',
      (tester) async {
    final recorder = StreamRecorder();
    final classifier = LocalScreamClassifier();
    final transport = ControlledTransport();
    final container = setup(recorder, classifier, transport);
    final notifier = container.read(dangerAudioProvider.notifier);
    expect(await notifier.startMonitoring(), true);
    for (var i = 0; i < 12; i++) {
      recorder.emit();
      await tester.pump(const Duration(milliseconds: 1200));
    }
    expect(classifier.classified, greaterThanOrEqualTo(10));
    expect(transport.calls.length, 1);
    expect(container.read(dangerAudioProvider).monitoring.delivery,
        AudioAlertDelivery.sending);
    expect(container.read(dangerAudioProvider).monitoring.health,
        AudioAnalysisHealth.healthy);
    expect(container.read(dangerAudioProvider).monitoring.droppedWindows, 0);
    await notifier.endLocalSession();
    expect(transport.tokens.single.isCancelled, true);
    transport.replies.single.complete(acceptedAlert());
    await tester.pump();
    expect(container.read(dangerAudioProvider).isMonitoring, false);
    container.dispose();
    await tester.pump();
  });

  testWidgets(
      'local inference failure switches to server and preserves model errors',
      (tester) async {
    final recorder = StreamRecorder();
    final classifier = LocalScreamClassifier()..failNext = true;
    final transport = ControlledTransport();
    final container = setup(recorder, classifier, transport);
    final notifier = container.read(dangerAudioProvider.notifier);
    expect(await notifier.startMonitoring(), true);
    recorder.emit();
    recorder.emit();
    await tester.pump(const Duration(milliseconds: 100));
    expect(transport.calls.single.containsKey('audio_base64'), true);
    transport.replies.single.completeError(const AudioRequestFailure(
        AudioFailureKind.model, 'AUDIO_MODEL_UNAVAILABLE'));
    await tester.pump();
    final status = container.read(dangerAudioProvider).monitoring;
    expect(status.mode, AudioAnalysisMode.server);
    expect(status.health, AudioAnalysisHealth.unavailable);
    expect(status.analysisFailure, AudioFailureKind.model);
    expect(status.lastErrorCode, 'AUDIO_MODEL_UNAVAILABLE');
    await notifier.endLocalSession();
    container.dispose();
    await tester.pump();
  });

  testWidgets(
      'server fallback recovers local recognition without restarting the microphone',
      (tester) async {
    var now = DateTime.utc(2026, 10, 28);
    final recorder = StreamRecorder();
    final classifier = LocalScreamClassifier()..isInitialized = false;
    final transport = ControlledTransport();
    final container = setup(recorder, classifier, transport, clock: () => now);
    final notifier = container.read(dangerAudioProvider.notifier);
    expect(await notifier.startMonitoring(), true);
    recorder.emit();
    recorder.emit();
    await tester.pump(const Duration(milliseconds: 100));
    transport.replies.single.complete({'signals': <dynamic>[]});
    await tester.pump();
    expect(container.read(dangerAudioProvider).monitoring.mode,
        AudioAnalysisMode.server);
    now = now.add(const Duration(seconds: 31));
    classifier.recoverOnInitialize = true;
    recorder.emit();
    await tester.pump(const Duration(milliseconds: 100));
    expect(classifier.classified, 1);
    expect(container.read(dangerAudioProvider).monitoring.mode,
        AudioAnalysisMode.onDevice);
    expect(transport.calls.last.containsKey('audio_base64'), false);
    await notifier.endLocalSession();
    transport.replies.last.complete(acceptedAlert());
    await tester.pump();
    container.dispose();
    await tester.pump();
  });

  testWidgets(
      'slow server discards expired backlog and fresh successes clear the warning',
      (tester) async {
    var now = DateTime.utc(2026, 10, 28);
    final recorder = StreamRecorder();
    final classifier = LocalScreamClassifier()..isInitialized = false;
    final transport = ControlledTransport();
    final container = setup(recorder, classifier, transport, clock: () => now);
    final notifier = container.read(dangerAudioProvider.notifier);
    await notifier.startMonitoring();
    recorder.emit();
    recorder.emit();
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 5; i++) {
      now = now.add(const Duration(milliseconds: 1200));
      recorder.emit();
      await tester.pump(const Duration(milliseconds: 1200));
    }
    transport.replies.single.completeError(const AudioRequestFailure(
        AudioFailureKind.network, 'AUDIO_DEADLINE',
        retryable: true));
    await tester.pump();
    now = now.add(const Duration(seconds: 2));
    recorder.emit();
    await tester.pump(const Duration(milliseconds: 100));
    expect(transport.calls.length, 2);
    final capturedAt =
        DateTime.parse(transport.calls.last['captured_at'] as String);
    expect(now.difference(capturedAt),
        lessThanOrEqualTo(const Duration(seconds: 4)));
    expect(container.read(dangerAudioProvider).monitoring.expiredWindows,
        greaterThan(0));
    transport.replies.last.complete({'signals': <dynamic>[]});
    await tester.pump();
    // Drain the surviving backlog, then process two fresh windows.
    for (var i = 0; i < 9; i++) {
      now = now.add(const Duration(milliseconds: 1200));
      recorder.emit();
      await tester.pump(const Duration(milliseconds: 1200));
      if (!transport.replies.last.isCompleted) {
        transport.replies.last.complete({'signals': <dynamic>[]});
        await tester.pump();
      }
    }
    final status = container.read(dangerAudioProvider).monitoring;
    expect(status.health, AudioAnalysisHealth.healthy);
    expect(status.expiredWindows + status.droppedWindows, greaterThan(0));
    await notifier.endLocalSession();
    container.dispose();
    await tester.pump();
  });

  testWidgets(
      'slow initial model download does not block microphone monitoring',
      (tester) async {
    final loading = Completer<void>();
    final recorder = StreamRecorder();
    final classifier = LocalScreamClassifier()
      ..isInitialized = false
      ..initializingWork = loading.future;
    final transport = ControlledTransport();
    final container = setup(recorder, classifier, transport);
    final notifier = container.read(dangerAudioProvider.notifier);
    final started = notifier.startMonitoring();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(await started, true);
    expect(recorder.isRecording, true);
    expect(container.read(dangerAudioProvider).monitoring.mode,
        AudioAnalysisMode.server);
    recorder.emit();
    recorder.emit();
    await tester.pump(const Duration(milliseconds: 100));
    transport.replies.single.complete({'signals': <dynamic>[]});
    await tester.pump();
    classifier.recoverOnInitialize = true;
    loading.complete();
    await tester.pump();
    recorder.emit();
    await tester.pump(const Duration(milliseconds: 100));
    expect(container.read(dangerAudioProvider).monitoring.mode,
        AudioAnalysisMode.onDevice);
    await notifier.endLocalSession();
    transport.replies.last.complete(acceptedAlert());
    await tester.pump();
    container.dispose();
    await tester.pump();
  });
}
