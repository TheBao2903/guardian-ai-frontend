/// ============================================================================
/// FILE: lib/core/device/audio/detection/yamnet_classifier.dart
/// MODULE: On-device Edge AI Audio Classifier (TensorFlow Lite YAMNet)
/// ROLE / RESPONSIBILITY:
///   - Tải và thực thi mô hình YAMNet TFLite trực tiếp trên thiết bị (On-device).
///   - Hỗ trợ đa nền tảng: Chạy Native TFLite trên Android/iOS/Desktop qua dart:io,
///     và graceful fallback trên Web (Chrome) qua conditional import chống lỗi JS FFI.
///   - Nhận tín hiệu âm thanh PCM 16-bit 16kHz, tiền xử lý thành Float32 [-1.0, 1.0].
///   - Suy luận (Inference) và ánh xạ 521 nhãn AudioSet thành DangerEventType.
///   - Quản lý trạng thái Model (State Machine) và hỗ trợ Preload ngầm.
/// ============================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_ai/core/device/audio/danger_audio_manager.dart';

import 'yamnet_classifier_factory_stub.dart'
    if (dart.library.io) 'yamnet_classifier_factory_io.dart'
    if (dart.library.js_interop) 'yamnet_classifier_factory_web.dart';

/// Trạng thái vòng đời của bộ phân loại âm thanh On-device
enum AudioClassifierStatus {
  notInitialized,
  initializing,
  ready,
  error,
}

/// Kết quả phân loại âm thanh từ On-device AI
class OnDeviceClassificationResult {
  final DangerEventType eventType;
  final String labelName;
  final double confidence;
  final int classIndex;

  const OnDeviceClassificationResult({
    required this.eventType,
    required this.labelName,
    required this.confidence,
    required this.classIndex,
  });

  @override
  String toString() =>
      'OnDeviceResult(type: ${eventType.name}, label: $labelName, conf: ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// Interface trừu tượng cho Audio Classifier
abstract class AudioClassifier {
  static const Map<int, DangerEventType> kAudioSetMapping = {
    // 1. Tiếng hét / Cứu giúp (Screaming, Shouting, Yell)
    11: DangerEventType.scream, // Screaming (Index 11)
    6: DangerEventType.scream, // Shout (Index 6)
    9: DangerEventType.scream, // Yell (Index 9)
    10: DangerEventType.scream, // Children shouting (Index 10)

    // 2. Tiếng khóc / Kêu cứu / Đau đớn (Distress Cry, Groan, Wail)
    19: DangerEventType.distressCry, // Crying, sobbing (Index 19)
    20: DangerEventType.distressCry, // Baby cry, infant cry (Index 20)
    22: DangerEventType.distressCry, // Wail, moan (Index 22)
    33: DangerEventType.distressCry, // Groan (Index 33)

    // 3. Tiếng súng / Tiếng nổ lớn (Gunshot, Explosion)
    421: DangerEventType.gunshot, // Gunshot, gunfire (Index 421)
    422: DangerEventType.gunshot, // Machine gun (Index 422)
    423: DangerEventType.gunshot, // Fusillade (Index 423)
    424: DangerEventType.gunshot, // Artillery fire (Index 424)

    // 4. Tiếng kính vỡ (Glass Shatter)
    434: DangerEventType.glassBreak, // Crack (Index 434)
    435: DangerEventType.glassBreak, // Glass (Index 435)
    437: DangerEventType.glassBreak, // Shatter (Index 437)

    // 5. Còi báo động / Xe ưu tiên (Sirens & Alarms)
    304: DangerEventType.alarm, // Car alarm (Index 304)
    316: DangerEventType.alarm, // Emergency vehicle (Index 316)
    317: DangerEventType.alarm, // Police car siren (Index 317)
    318: DangerEventType.alarm, // Ambulance siren (Index 318)
    319: DangerEventType.alarm, // Fire engine siren (Index 319)
    382: DangerEventType.alarm, // Alarm (Index 382)
    390: DangerEventType.alarm, // Siren (Index 390)
    391: DangerEventType.alarm, // Civil defense siren (Index 391)
    393: DangerEventType.alarm, // Smoke detector, smoke alarm (Index 393)
    394: DangerEventType.alarm, // Fire alarm (Index 394)
  };

  bool get isInitialized;
  AudioClassifierStatus get status;
  Future<void> initialize();
  Future<List<OnDeviceClassificationResult>> classify(List<int> pcm16Bytes);
  void dispose();

  factory AudioClassifier() => createAudioClassifier();
}

/// Top-level kAudioSetMapping cho các module truy cập trực tiếp
const Map<int, DangerEventType> kAudioSetMapping =
    AudioClassifier.kAudioSetMapping;

/// Lớp đại diện tương thích ngược cho YamnetTfliteClassifier
typedef YamnetTfliteClassifier = AudioClassifier;

/// Provider toàn cục cho AudioClassifier
final audioClassifierProvider = Provider<AudioClassifier>((ref) {
  final classifier = AudioClassifier();
  ref.onDispose(() => classifier.dispose());
  return classifier;
});
