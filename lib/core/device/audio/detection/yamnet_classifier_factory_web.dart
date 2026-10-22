/// Web-safe AudioClassifier implementation that falls back gracefully without native FFI
library;

import 'package:flutter/foundation.dart';
import 'yamnet_classifier.dart';

class YamnetWebClassifier implements AudioClassifier {
  @override
  bool get isInitialized => false;

  @override
  AudioClassifierStatus get status => AudioClassifierStatus.notInitialized;

  @override
  Future<void> initialize() async {
    debugPrint(
        'YamnetWebClassifier: On-device TFLite FFI không hỗ trợ trên trình duyệt Web (Chrome). Hệ thống sẽ tự động sử dụng Cloud Backend AI để phân tích.');
  }

  @override
  Future<List<OnDeviceClassificationResult>> classify(
      List<int> pcm16Bytes) async {
    // Trên web, On-device rỗng để tự động fallback sang Backend AI an toàn
    return [];
  }

  @override
  void dispose() {}
}

AudioClassifier createAudioClassifier() => YamnetWebClassifier();
