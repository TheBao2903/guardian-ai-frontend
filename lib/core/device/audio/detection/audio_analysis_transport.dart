import 'dart:async';
import 'package:dio/dio.dart';
import 'audio_monitoring_status.dart';

class AudioRequestFailure implements Exception {
  const AudioRequestFailure(this.kind, this.code, {this.retryable = false});
  final AudioFailureKind kind;
  final String code;
  final bool retryable;
}

abstract class AudioAnalysisTransport {
  Future<dynamic> post(String path, Map<String, dynamic> data,
      {required CancelToken cancelToken, required Duration budget});
}

/// A total deadline cancels the actual upload, not just the awaiting Future.
class DioAudioAnalysisTransport implements AudioAnalysisTransport {
  DioAudioAnalysisTransport(this.dio);
  final Dio dio;

  @override
  Future<dynamic> post(String path, Map<String, dynamic> data,
      {required CancelToken cancelToken, required Duration budget}) async {
    final timer = Timer(budget, () => cancelToken.cancel('AUDIO_DEADLINE'));
    try {
      final options = Options(
        method: 'POST',
        sendTimeout: const Duration(seconds: 3),
        receiveTimeout: budget,
      ).compose(dio.options, path, data: data, cancelToken: cancelToken)
        ..connectTimeout = const Duration(seconds: 2);
      final response =
          await dio.fetch<dynamic>(options).timeout(budget, onTimeout: () {
        cancelToken.cancel('AUDIO_DEADLINE');
        throw const AudioRequestFailure(
            AudioFailureKind.network, 'AUDIO_DEADLINE',
            retryable: true);
      });
      final body = response.data;
      return body is Map && body.containsKey('data') ? body['data'] : body;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final body = error.response?.data;
      final details = body is Map ? body['error'] : null;
      final code = details is Map ? '${details['code'] ?? ''}' : '';
      if (status == 401 || status == 403) {
        throw AudioRequestFailure(AudioFailureKind.authentication, code);
      }
      if (code == 'STALE_AUDIO' || code == 'INACTIVE_SAFETY_CHECK') {
        throw AudioRequestFailure(AudioFailureKind.stale, code);
      }
      if (code == 'AUDIO_MODEL_UNAVAILABLE' ||
          code == 'AUDIO_INFERENCE_FAILED') {
        throw AudioRequestFailure(AudioFailureKind.model, code);
      }
      if (status == null) {
        throw AudioRequestFailure(AudioFailureKind.network,
            cancelToken.cancelError?.error?.toString() ?? error.type.name,
            retryable: !cancelToken.isCancelled ||
                cancelToken.cancelError?.error == 'AUDIO_DEADLINE');
      }
      throw AudioRequestFailure(
          AudioFailureKind.server, code.isEmpty ? 'HTTP_$status' : code,
          retryable: status == 429 || status >= 500);
    } finally {
      timer.cancel();
    }
  }
}
