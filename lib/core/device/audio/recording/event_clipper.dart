/// Event Clipper for assembling audio clips
library;

import 'package:flutter/foundation.dart';

import 'audio_recorder_service.dart';

/// Event type for audio detection
enum AudioEventType {
  scream,
  distressCry,
  gunshot,
  glassBreak,
  alarm,
  manualSos,
  unknown,
}

/// Configuration for event clipper
class EventClipperConfig {
  /// Maximum pre-roll duration in seconds
  final double maxPreRollSeconds;

  /// Maximum post-roll duration in seconds
  final double maxPostRollSeconds;

  /// Maximum total clip duration in seconds
  final double maxTotalDurationSeconds;

  /// Maximum clips per session
  final int maxClipsPerSession;

  /// Event aggregation window in seconds
  final double eventAggregationWindowSeconds;

  /// Maximum pending uploads
  final int maxPendingUploads;

  /// Maximum total pending bytes
  final int maxPendingBytes;

  const EventClipperConfig({
    this.maxPreRollSeconds = 5.0,
    this.maxPostRollSeconds = 5.0,
    this.maxTotalDurationSeconds = 15.0,
    this.maxClipsPerSession = 3,
    this.eventAggregationWindowSeconds = 10.0,
    this.maxPendingUploads = 2,
    this.maxPendingBytes = 10 * 1024 * 1024, // 10MB
  });
}

/// Represention of an audio event clip
class AudioEventClip {
  /// Unique ID for this clip
  final String clipId;

  /// Session ID this clip belongs to
  final String? sessionId;

  /// Event type detected
  final AudioEventType eventType;

  /// Confidence score from detector (0.0 - 1.0)
  final double confidence;

  /// Pre-roll duration used
  final double preRollSeconds;

  /// Post-roll duration used
  final double postRollSeconds;

  /// Total duration of clip
  final double totalDurationSeconds;

  /// Audio data (WAV format)
  final Uint8List audioData;

  /// Timestamp when clip was created
  final DateTime createdAt;

  /// Status of this clip
  final AudioClipStatus status;

  /// Number of retry attempts
  final int retryCount;

  const AudioEventClip({
    required this.clipId,
    this.sessionId,
    required this.eventType,
    required this.confidence,
    required this.preRollSeconds,
    required this.postRollSeconds,
    required this.totalDurationSeconds,
    required this.audioData,
    required this.createdAt,
    this.status = AudioClipStatus.pending,
    this.retryCount = 0,
  });

  AudioEventClip copyWith({
    String? clipId,
    String? sessionId,
    AudioEventType? eventType,
    double? confidence,
    double? preRollSeconds,
    double? postRollSeconds,
    double? totalDurationSeconds,
    Uint8List? audioData,
    DateTime? createdAt,
    AudioClipStatus? status,
    int? retryCount,
  }) {
    return AudioEventClip(
      clipId: clipId ?? this.clipId,
      sessionId: sessionId ?? this.sessionId,
      eventType: eventType ?? this.eventType,
      confidence: confidence ?? this.confidence,
      preRollSeconds: preRollSeconds ?? this.preRollSeconds,
      postRollSeconds: postRollSeconds ?? this.postRollSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      audioData: audioData ?? this.audioData,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// File size in bytes
  int get fileSizeBytes => audioData.length;

  /// Event type as string for API
  String get eventTypeString {
    switch (eventType) {
      case AudioEventType.scream:
        return 'SCREAM';
      case AudioEventType.distressCry:
        return 'DISTRESS_CRY';
      case AudioEventType.gunshot:
        return 'GUNSHOT';
      case AudioEventType.glassBreak:
        return 'GLASS_BREAK';
      case AudioEventType.alarm:
        return 'ALARM';
      case AudioEventType.manualSos:
        return 'MANUAL_SOS';
      case AudioEventType.unknown:
        return 'UNKNOWN';
    }
  }
}

/// Status of audio clip
enum AudioClipStatus {
  pending, // Created, not yet uploading
  uploading, // Currently uploading
  uploaded, // Successfully uploaded
  failed, // Upload failed
}

/// Event clipper that assembles clips from ring buffer
class EventClipper {
  final EventClipperConfig config;
  final AudioRecorderService _recorder;

  /// Pending clips queue
  final List<AudioEventClip> _pendingClips = [];

  /// Clips created this session
  int _clipsThisSession = 0;

  /// Last event timestamp for aggregation
  DateTime? _lastEventTime;

  EventClipper({
    EventClipperConfig? config,
    required AudioRecorderService recorder,
  })  : config = config ?? const EventClipperConfig(),
        _recorder = recorder;

  /// Get pending clips count
  int get pendingCount => _pendingClips.length;

  /// Get total pending bytes
  int get totalPendingBytes =>
      _pendingClips.fold(0, (sum, clip) => sum + clip.fileSizeBytes);

  /// Get clips this session
  int get clipsThisSession => _clipsThisSession;

  /// Check if can create new clip
  bool get canCreateClip {
    if (_clipsThisSession >= config.maxClipsPerSession) {
      return false;
    }
    if (_pendingClips.length >= config.maxPendingUploads) {
      return false;
    }
    if (totalPendingBytes >= config.maxPendingBytes) {
      return false;
    }
    return true;
  }

  /// Check if new trigger should be aggregated with recent event
  bool shouldAggregateEvent() {
    if (_lastEventTime == null) return false;

    final elapsed =
        DateTime.now().difference(_lastEventTime!).inMilliseconds / 1000;
    return elapsed < config.eventAggregationWindowSeconds;
  }

  /// Create audio clip from current buffer state
  ///
  /// [eventType] - Type of event detected
  /// [confidence] - Confidence score (0.0 - 1.0)
  /// [postRollDuration] - How long to capture after trigger
  AudioEventClip? createClip({
    required AudioEventType eventType,
    required double confidence,
    String? sessionId,
    double? postRollDuration,
  }) {
    // Check limits
    if (!canCreateClip) {
      debugPrint('EventClipper: Cannot create clip - limits exceeded');
      return null;
    }

    // Check if should aggregate
    if (shouldAggregateEvent()) {
      debugPrint('EventClipper: Aggregating with recent event');
      return null;
    }

    // Take snapshot of pre-roll buffer
    final preRollData = _recorder.takeSnapshot();
    final preRollSeconds = preRollData.length / 16000 / 2; // Approximate

    // Determine actual post-roll duration (capped by config)
    final actualPostRollSeconds =
        (postRollDuration ?? config.maxPostRollSeconds)
            .clamp(0.0, config.maxPostRollSeconds);

    // Calculate total duration
    final totalDuration = preRollSeconds + actualPostRollSeconds;
    if (totalDuration > config.maxTotalDurationSeconds) {
      debugPrint('EventClipper: Clip would exceed max duration');
      return null;
    }

    // Create clip
    final clipId = '${DateTime.now().millisecondsSinceEpoch}_${eventType.name}';
    final clip = AudioEventClip(
      clipId: clipId,
      sessionId: sessionId,
      eventType: eventType,
      confidence: confidence,
      preRollSeconds: preRollSeconds,
      postRollSeconds: actualPostRollSeconds,
      totalDurationSeconds: totalDuration,
      audioData: preRollData,
      createdAt: DateTime.now(),
      status: AudioClipStatus.pending,
    );

    // Add to queue
    _pendingClips.add(clip);
    _clipsThisSession++;
    _lastEventTime = DateTime.now();

    debugPrint(
        'EventClipper: Created clip $clipId, pending: ${_pendingClips.length}');
    return clip;
  }

  /// Get next clip to upload
  AudioEventClip? getNextClip() {
    if (_pendingClips.isEmpty) return null;
    return _pendingClips.firstWhere(
      (c) =>
          c.status == AudioClipStatus.pending ||
          c.status == AudioClipStatus.failed,
      orElse: () => _pendingClips.first,
    );
  }

  /// Mark clip as uploading
  void markUploading(String clipId) {
    final index = _pendingClips.indexWhere((c) => c.clipId == clipId);
    if (index >= 0) {
      _pendingClips[index] = _pendingClips[index].copyWith(
        status: AudioClipStatus.uploading,
      );
    }
  }

  /// Mark clip as uploaded (remove from pending)
  void markUploaded(String clipId) {
    _pendingClips.removeWhere((c) => c.clipId == clipId);
    debugPrint(
        'EventClipper: Clip $clipId uploaded, pending: ${_pendingClips.length}');
  }

  /// Mark clip as failed
  void markFailed(String clipId, {int maxRetries = 3}) {
    final index = _pendingClips.indexWhere((c) => c.clipId == clipId);
    if (index >= 0) {
      final clip = _pendingClips[index];
      if (clip.retryCount >= maxRetries) {
        // Max retries exceeded, remove
        _pendingClips.removeAt(index);
        debugPrint('EventClipper: Clip $clipId exceeded max retries, dropped');
      } else {
        // Increment retry count
        _pendingClips[index] = clip.copyWith(
          status: AudioClipStatus.failed,
          retryCount: clip.retryCount + 1,
        );
      }
    }
  }

  /// Clear all pending clips (when session ends)
  void clearAll() {
    _pendingClips.clear();
    _clipsThisSession = 0;
    _lastEventTime = null;
    debugPrint('EventClipper: Cleared all pending clips');
  }

  /// Reset session counter (when new session starts)
  void resetSession() {
    _clipsThisSession = 0;
    _lastEventTime = null;
    debugPrint('EventClipper: Session reset');
  }

  /// Get status summary
  Map<String, dynamic> getStatus() {
    return {
      'pendingClips': _pendingClips.length,
      'totalPendingBytes': totalPendingBytes,
      'clipsThisSession': _clipsThisSession,
      'canCreateClip': canCreateClip,
      'lastEventTime': _lastEventTime?.toIso8601String(),
      'config': {
        'maxPreRollSeconds': config.maxPreRollSeconds,
        'maxPostRollSeconds': config.maxPostRollSeconds,
        'maxTotalDurationSeconds': config.maxTotalDurationSeconds,
        'maxClipsPerSession': config.maxClipsPerSession,
        'maxPendingUploads': config.maxPendingUploads,
      },
    };
  }
}
