/// Upload Queue Service for audio clips
library;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../error/app_exception.dart';
import '../../../network/api_client.dart';
import 'event_clipper.dart';

/// Upload status callback
typedef UploadStatusCallback = void Function(UploadStatus status);

/// Upload status
class UploadStatus {
  final String clipId;
  final UploadState state;
  final double progress;
  final String? error;

  const UploadStatus({
    required this.clipId,
    required this.state,
    this.progress = 0.0,
    this.error,
  });
}

enum UploadState {
  pending,
  uploading,
  completed,
  failed,
}

/// Configuration for upload queue
class UploadQueueConfig {
  /// Maximum concurrent uploads
  final int maxConcurrentUploads;

  /// Maximum retry attempts per clip
  final int maxRetries;

  /// Base backoff duration in seconds
  final int backoffBaseSeconds;

  /// Maximum backoff duration in seconds
  final int maxBackoffSeconds;

  const UploadQueueConfig({
    this.maxConcurrentUploads = 2,
    this.maxRetries = 3,
    this.backoffBaseSeconds = 2,
    this.maxBackoffSeconds = 30,
  });
}

/// Upload queue service with proper API client integration
class UploadQueueService {
  final ApiClient _apiClient;
  final UploadQueueConfig config;

  final List<AudioEventClip> _queue = [];
  int _activeUploads = 0;
  final Map<String, int> _retryCount = {};
  UploadStatusCallback? onStatusChange;

  UploadQueueService({
    required ApiClient apiClient,
    this.config = const UploadQueueConfig(),
  }) : _apiClient = apiClient;

  /// Create from Ref (Riverpod)
  factory UploadQueueService.fromRef(Ref ref) {
    return UploadQueueService(
      apiClient: ref.read(apiClientProvider),
    );
  }

  /// Add clip to upload queue
  Future<void> enqueue(AudioEventClip clip) async {
    if (_queue.any((c) => c.clipId == clip.clipId)) {
      debugPrint('UploadQueue: Clip ${clip.clipId} already in queue');
      return;
    }

    _queue.add(clip);
    _retryCount[clip.clipId] = 0;

    // Trigger upload if below concurrent limit
    _processQueue();

    onStatusChange?.call(UploadStatus(
      clipId: clip.clipId,
      state: UploadState.pending,
    ));
  }

  /// Process queue - start uploads if capacity available
  void _processQueue() {
    if (_activeUploads >= config.maxConcurrentUploads) {
      return;
    }

    // Find next pending clip
    if (_queue.isEmpty) return;

    final pendingClip = _queue.firstWhere(
      (c) => _retryCount[c.clipId]! < config.maxRetries,
      orElse: () => _queue.first,
    );

    if (pendingClip.status == AudioClipStatus.uploaded) {
      return; // Already uploaded
    }

    _startUpload(pendingClip);
  }

  /// Start upload for a clip
  Future<void> _startUpload(AudioEventClip clip) async {
    if (_activeUploads >= config.maxConcurrentUploads) {
      return;
    }

    _activeUploads++;
    onStatusChange?.call(UploadStatus(
      clipId: clip.clipId,
      state: UploadState.uploading,
    ));

    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          clip.audioData,
          filename: 'clip_${clip.clipId}.wav',
        ),
        'event_id': clip.clipId,
        if (clip.sessionId != null) 'session_id': clip.sessionId,
        'event_type': clip.eventTypeString,
        'confidence': clip.confidence.toString(),
        'pre_event_seconds': clip.preRollSeconds.toString(),
        'post_event_seconds': clip.postRollSeconds.toString(),
        'duration_seconds': clip.totalDurationSeconds.toString(),
      });

      // Use API client which automatically includes Bearer token
      await _apiClient.post<dynamic>(
        '/recordings/upload',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // Success
      _activeUploads--;
      _queue.removeWhere((c) => c.clipId == clip.clipId);
      _retryCount.remove(clip.clipId);

      onStatusChange?.call(UploadStatus(
        clipId: clip.clipId,
        state: UploadState.completed,
      ));

      // Process next in queue
      _processQueue();
    } on DioException catch (e) {
      _activeUploads--;
      _handleUploadError(clip, e);
    } catch (e) {
      _activeUploads--;
      _handleUploadError(clip, e);
    }
  }

  /// Handle upload error with retry
  void _handleUploadError(AudioEventClip clip, dynamic error) {
    final retries = (_retryCount[clip.clipId] ?? 0) + 1;
    _retryCount[clip.clipId] = retries;

    if (retries < config.maxRetries && _isRetryableError(error)) {
      // Calculate backoff
      final backoffSeconds = (config.backoffBaseSeconds * (1 << (retries - 1)))
          .clamp(1, config.maxBackoffSeconds);

      debugPrint(
          'UploadQueue: Retrying ${clip.clipId} in ${backoffSeconds}s (attempt $retries/${config.maxRetries})');

      // Schedule retry
      Future.delayed(Duration(seconds: backoffSeconds), () {
        _processQueue();
      });
    } else {
      // Max retries exceeded or non-retryable error
      debugPrint('UploadQueue: Clip ${clip.clipId} failed permanently: $error');

      onStatusChange?.call(UploadStatus(
        clipId: clip.clipId,
        state: UploadState.failed,
        error: error.toString(),
      ));

      // Remove from queue
      _queue.removeWhere((c) => c.clipId == clip.clipId);
      _retryCount.remove(clip.clipId);

      // Process next in queue
      _processQueue();
    }
  }

  /// Check if error is retryable
  bool _isRetryableError(dynamic error) {
    if (error is NetworkException) {
      return true;
    }
    if (error is ServerException) {
      final code = error.statusCode;
      return code == null || (code >= 500 && code < 600);
    }
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.cancel:
          return true;
        case DioExceptionType.badResponse:
          // Retry on 5xx errors
          final statusCode = error.response?.statusCode;
          return statusCode != null && statusCode >= 500 && statusCode < 600;
        default:
          return false;
      }
    }
    return false;
  }

  /// Get queue status
  Map<String, dynamic> getStatus() {
    return {
      'queueLength': _queue.length,
      'activeUploads': _activeUploads,
      'maxConcurrentUploads': config.maxConcurrentUploads,
      'retryCounts': _retryCount,
    };
  }

  /// Đợi hàng đợi upload hoàn thành toàn bộ các file đang tải dở
  Future<void> flush({Duration timeout = const Duration(seconds: 4)}) async {
    if (_queue.isEmpty && _activeUploads == 0) return;
    final stopwatch = Stopwatch()..start();
    while ((_queue.isNotEmpty || _activeUploads > 0) &&
        stopwatch.elapsed < timeout) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Cancel all pending uploads
  void cancelAll() {
    _queue.clear();
    _retryCount.clear();
    _activeUploads = 0;
    debugPrint('UploadQueue: All uploads cancelled');
  }

  /// Get number of pending clips
  int get pendingCount => _queue.length;

  /// Get number of active uploads
  int get activeUploads => _activeUploads;
}
