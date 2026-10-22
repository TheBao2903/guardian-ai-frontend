/// Audio Detection Service - ML-based Event Detection
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../recording/event_clipper.dart';
import '../recording/ring_buffer.dart';
import 'cooldown_manager.dart';

/// Detection result from audio analysis
class DetectionResult {
  /// Whether an event was detected
  final bool detected;

  /// Type of event detected (null if not detected)
  final AudioEventType? eventType;

  /// Confidence score (0.0 - 1.0)
  final double confidence;

  /// Timestamp of detection
  final DateTime timestamp;

  /// Amplitude level that triggered detection
  final double amplitude;

  const DetectionResult({
    required this.detected,
    this.eventType,
    required this.confidence,
    required this.timestamp,
    required this.amplitude,
  });

  factory DetectionResult.none() => DetectionResult(
        detected: false,
        confidence: 0.0,
        timestamp: DateTime.now(),
        amplitude: 0.0,
      );
}

/// Configuration for audio detection
class AudioDetectionConfig {
  /// Minimum confidence threshold for detection (0.0 - 1.0)
  final double confidenceThreshold;

  /// Minimum amplitude to consider (dB, typically -160 to 0)
  final double minAmplitude;

  /// Window size for analysis (milliseconds)
  final int windowSizeMs;

  /// Detection cooldown per event type (milliseconds)
  final Map<String, int> cooldowns;

  /// Whether detection is enabled
  final bool enabled;

  const AudioDetectionConfig({
    this.confidenceThreshold = 0.7,
    this.minAmplitude = -40.0,
    this.windowSizeMs = 500,
    this.cooldowns = const {
      'scream': 30000, // 30 seconds
      'gunshot': 60000, // 1 minute
      'glassBreak': 30000,
      'alarm': 30000,
      'distressCry': 15000,
    },
    this.enabled = true,
  });
}

/// Audio Detection Service
///
/// Detects audio events using ML models (YAMNet, vocal burst, etc.)
///
/// NOTE: This is a STUB implementation. Real implementation would use:
/// - YAMNet for general sound classification
/// - Custom vocal burst detector
/// - Platform-specific audio processing
class AudioDetectionService {
  final AudioDetectionConfig config;
  final CooldownManager _cooldownManager;

  /// Callback when an event is detected
  void Function(DetectionResult result)? onDetection;

  /// Stream controller for detection results
  final StreamController<DetectionResult> _detectionController =
      StreamController<DetectionResult>.broadcast();

  /// Whether service is running
  bool _isRunning = false;

  AudioDetectionService({
    AudioDetectionConfig? config,
    CooldownManager? cooldownManager,
  })  : config = config ?? const AudioDetectionConfig(),
        _cooldownManager = cooldownManager ??
            CooldownManager(
              cooldowns: config?.cooldowns ?? const {},
              defaultCooldownMs: 10000,
            );

  /// Stream of detection results
  Stream<DetectionResult> get detectionStream => _detectionController.stream;

  /// Whether detection is currently running
  bool get isRunning => _isRunning;

  /// Cooldown manager for external access
  CooldownManager get cooldownManager => _cooldownManager;

  /// Start detection service
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    debugPrint('AudioDetectionService: Started');
  }

  /// Stop detection service
  void stop() {
    _isRunning = false;
    _cooldownManager.clearAll();
    debugPrint('AudioDetectionService: Stopped');
  }

  /// Process audio amplitude for detection
  ///
  /// Called from audio recorder's amplitude monitoring
  /// [amplitude] - Current amplitude in dB (typically -160 to 0)
  /// [buffer] - Current ring buffer for additional analysis
  void processAmplitude(double amplitude, [RingBuffer? buffer]) {
    if (!_isRunning || !config.enabled) return;

    // Quick amplitude check (pre-filter)
    if (amplitude < config.minAmplitude) {
      return;
    }

    // Run detection (stub - real impl would use ML model)
    final result = _runDetection(amplitude);

    if (result.detected) {
      final eventTypeStr = result.eventType?.name ?? 'unknown';

      // Check cooldown
      if (_cooldownManager.isInCooldown(eventTypeStr)) {
        debugPrint('AudioDetectionService: $eventTypeStr in cooldown');
        return;
      }

      // Trigger cooldown
      _cooldownManager.trigger(eventTypeStr);

      // Emit result
      _detectionController.add(result);
      onDetection?.call(result);

      debugPrint('AudioDetectionService: Detected ${result.eventType} '
          '(confidence: ${result.confidence.toStringAsFixed(2)})');
    }
  }

  /// Run detection algorithm
  ///
  /// STUB: In production, this would:
  /// 1. Extract features from audio buffer
  /// 2. Run YAMNet inference
  /// 3. Run vocal burst classifier
  /// 4. Aggregate results
  DetectionResult _runDetection(double amplitude) {
    // Normalize amplitude to 0-1 range
    // dB range is typically -160 to 0
    final normalizedAmplitude = ((amplitude + 160) / 160).clamp(0.0, 1.0);

    // Simple threshold-based detection (STUB)
    // Real implementation would use ML model
    if (normalizedAmplitude > config.confidenceThreshold) {
      // Simulate different event types based on amplitude
      AudioEventType eventType;
      double confidence;

      if (normalizedAmplitude > 0.95) {
        eventType = AudioEventType.gunshot;
        confidence = 0.9;
      } else if (normalizedAmplitude > 0.85) {
        eventType = AudioEventType.scream;
        confidence = 0.85;
      } else if (normalizedAmplitude > 0.75) {
        eventType = AudioEventType.alarm;
        confidence = 0.75;
      } else if (normalizedAmplitude > 0.7) {
        eventType = AudioEventType.distressCry;
        confidence = 0.72;
      } else {
        // Below threshold
        return DetectionResult.none();
      }

      return DetectionResult(
        detected: true,
        eventType: eventType,
        confidence: confidence,
        timestamp: DateTime.now(),
        amplitude: amplitude,
      );
    }

    return DetectionResult.none();
  }

  /// Manually trigger a detection (for testing)
  void triggerManually({
    required AudioEventType eventType,
    required double confidence,
    double amplitude = -20.0,
  }) {
    final result = DetectionResult(
      detected: true,
      eventType: eventType,
      confidence: confidence,
      timestamp: DateTime.now(),
      amplitude: amplitude,
    );

    final eventTypeStr = result.eventType?.name ?? 'unknown';

    if (_cooldownManager.isInCooldown(eventTypeStr)) {
      debugPrint('AudioDetectionService: $eventTypeStr in cooldown');
      return;
    }

    _cooldownManager.trigger(eventTypeStr);
    _detectionController.add(result);
    onDetection?.call(result);
  }

  /// Dispose resources
  void dispose() {
    stop();
    _detectionController.close();
  }

  /// Get detection status
  Map<String, dynamic> getStatus() {
    return {
      'isRunning': isRunning,
      'enabled': config.enabled,
      'confidenceThreshold': config.confidenceThreshold,
      'minAmplitude': config.minAmplitude,
      'cooldowns': _cooldownManager.getCooldownStatus(),
      'globalCooldownActive': _cooldownManager.isGlobalCooldownActive,
      'globalCooldownRemaining': _cooldownManager.globalCooldownRemaining,
    };
  }
}
