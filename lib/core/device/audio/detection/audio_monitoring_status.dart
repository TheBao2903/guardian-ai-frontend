/// Health is based on current work, never on lifetime loss counters.
enum AudioAnalysisMode { initializing, onDevice, server }

enum AudioAnalysisHealth { waiting, healthy, delayed, unavailable }

enum AudioAlertDelivery { idle, sending, retrying, accepted, failed, expired }

enum AudioFailureKind { none, network, authentication, model, stale, server }

class AudioMonitoringStatus {
  const AudioMonitoringStatus({
    this.mode = AudioAnalysisMode.initializing,
    this.health = AudioAnalysisHealth.waiting,
    this.delivery = AudioAlertDelivery.idle,
    this.analysisFailure = AudioFailureKind.none,
    this.deliveryFailure = AudioFailureKind.none,
    this.pendingWindows = 0,
    this.droppedWindows = 0,
    this.expiredWindows = 0,
    this.analysisMilliseconds = 0,
    this.resultAgeMilliseconds = 0,
    this.processedWindows = 0,
    this.lastErrorCode = '',
  });

  final AudioAnalysisMode mode;
  final AudioAnalysisHealth health;
  final AudioAlertDelivery delivery;
  final AudioFailureKind analysisFailure, deliveryFailure;
  final int pendingWindows, droppedWindows, expiredWindows;
  final int analysisMilliseconds;
  final int resultAgeMilliseconds, processedWindows;
  final String lastErrorCode;

  AudioMonitoringStatus copyWith({
    AudioAnalysisMode? mode,
    AudioAnalysisHealth? health,
    AudioAlertDelivery? delivery,
    AudioFailureKind? analysisFailure,
    AudioFailureKind? deliveryFailure,
    int? pendingWindows,
    int? droppedWindows,
    int? expiredWindows,
    int? analysisMilliseconds,
    int? resultAgeMilliseconds,
    int? processedWindows,
    String? lastErrorCode,
  }) =>
      AudioMonitoringStatus(
        mode: mode ?? this.mode,
        health: health ?? this.health,
        delivery: delivery ?? this.delivery,
        analysisFailure: analysisFailure ?? this.analysisFailure,
        deliveryFailure: deliveryFailure ?? this.deliveryFailure,
        pendingWindows: pendingWindows ?? this.pendingWindows,
        droppedWindows: droppedWindows ?? this.droppedWindows,
        expiredWindows: expiredWindows ?? this.expiredWindows,
        analysisMilliseconds: analysisMilliseconds ?? this.analysisMilliseconds,
        resultAgeMilliseconds:
            resultAgeMilliseconds ?? this.resultAgeMilliseconds,
        processedWindows: processedWindows ?? this.processedWindows,
        lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      );
}

/// Two fresh successes clear a transient failure; old losses remain diagnostic.
class AudioHealthTracker {
  int _losses = 0, _freshSuccesses = 0;
  AudioAnalysisHealth health = AudioAnalysisHealth.waiting;

  void failed() {
    _freshSuccesses = 0;
    health = AudioAnalysisHealth.unavailable;
  }

  AudioAnalysisHealth success(
      {required int totalLosses, required Duration age}) {
    if (totalLosses > _losses || age > const Duration(seconds: 3)) {
      _freshSuccesses = 0;
      health = AudioAnalysisHealth.delayed;
    } else if (++_freshSuccesses >= 2 ||
        health == AudioAnalysisHealth.waiting) {
      health = AudioAnalysisHealth.healthy;
    }
    _losses = totalLosses;
    return health;
  }
}
