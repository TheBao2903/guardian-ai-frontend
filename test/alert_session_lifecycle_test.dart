import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/device/audio/danger_audio_providers.dart';
import 'package:guardian_ai/core/device/audio/detection/yamnet_classifier.dart';
import 'package:guardian_ai/core/device/audio/recording/audio_recorder_service.dart';
import 'package:guardian_ai/core/network/api_client.dart';
import 'package:guardian_ai/core/storage/secure_storage.dart';
import 'package:guardian_ai/features/home/presentation/widgets/danger_alert_sheet.dart';

class PendingApi extends ApiClient {
  PendingApi()
      : super(
            storage: SecureStorage(),
            customDio: Dio(BaseOptions(baseUrl: 'http://localhost/api/v1')));
  final pending = Completer<Response<dynamic>>();

  @override
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await pending.future as Response<T>;
  }

  void completeAlert() {
    final now = DateTime.now().toUtc();
    pending.complete(Response<dynamic>(
      requestOptions: RequestOptions(path: '/detection/alerts/current'),
      data: {
        'data': {
          'alert_id': 'a' * 40,
          'status': 'PENDING',
          'deadline_at': now.add(const Duration(seconds: 10)).toIso8601String(),
          'server_time': now.toIso8601String(),
        },
      },
    ));
  }
}

class SilentRecorder implements AudioRecorderService {
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
  @override
  set onAudioChunk(dynamic callback) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SilentClassifier implements AudioClassifier {
  @override
  void dispose() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final logout in [false, true]) {
    testWidgets(
        logout
            ? 'logout rejects in-flight alert from the old session'
            : 'stopping microphone preserves in-flight server alert',
        (tester) async {
      final api = PendingApi();
      final container = ProviderContainer(overrides: [
        dangerAudioApiClientProvider.overrideWithValue(api),
        dangerAudioRecorderProvider.overrideWithValue(SilentRecorder()),
        audioClassifierProvider.overrideWithValue(SilentClassifier()),
      ]);
      final notifier = container.read(dangerAudioProvider.notifier);
      final request = notifier.syncCurrentAlert();
      if (logout) {
        await notifier.endLocalSession();
      } else {
        await notifier.stopMonitoring();
      }
      api.completeAlert();
      await request;
      expect(container.read(dangerAlertProvider).isShowing, !logout);
      container.dispose();
      await tester.pump();
    });
  }
}
