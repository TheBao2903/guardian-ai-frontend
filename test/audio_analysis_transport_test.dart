import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_analysis_transport.dart';
import 'package:guardian_ai/core/device/audio/detection/audio_monitoring_status.dart';

class WaitingAdapter implements HttpClientAdapter {
  RequestOptions? request;
  bool cancelled = false;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    request = options;
    try {
      await cancelFuture;
    } finally {
      cancelled = true;
    }
    throw DioException.requestCancelled(
        requestOptions: options, reason: 'cancelled');
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('total deadline cancels the actual request and bounds all phases',
      () async {
    final adapter = WaitingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter;
    final token = CancelToken();
    Object? failure;
    final request = DioAudioAnalysisTransport(dio)
        .post('/audio', {},
            cancelToken: token, budget: const Duration(milliseconds: 100))
        .catchError((Object error) {
      failure = error;
      return null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(failure, isNull);
    expect(adapter.request!.method, 'POST');
    expect(adapter.request!.connectTimeout, const Duration(seconds: 2));
    expect(adapter.request!.sendTimeout, const Duration(seconds: 3));
    await request;
    await Future<void>.delayed(Duration.zero);
    expect(token.isCancelled, true);
    expect(adapter.cancelled, true);
    expect((failure as AudioRequestFailure).kind, AudioFailureKind.network);
    expect((failure as AudioRequestFailure).retryable, true);
    dio.close();
  });

  for (final entry in {
    'STALE_AUDIO': AudioFailureKind.stale,
    'AUDIO_MODEL_UNAVAILABLE': AudioFailureKind.model,
    'AUDIO_INFERENCE_FAILED': AudioFailureKind.model,
  }.entries) {
    test('preserves backend error code ${entry.key}', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: options, statusCode: 503, data: {
              'error': {'code': entry.key}
            })));
      }));
      await expectLater(
          DioAudioAnalysisTransport(dio).post('/audio', {},
              cancelToken: CancelToken(), budget: const Duration(seconds: 4)),
          throwsA(isA<AudioRequestFailure>()
              .having((e) => e.kind, 'kind', entry.value)
              .having((e) => e.code, 'code', entry.key)));
      dio.close();
    });
  }
}
