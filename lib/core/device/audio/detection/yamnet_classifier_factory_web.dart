/// Same-origin YAMNet ONNX/WASM inference in a Web Worker.
library;

import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'yamnet_classifier.dart';

@JS('guardianAudioClassifier.initialize')
external JSPromise<JSAny?> _initialize();
@JS('guardianAudioClassifier.classify')
external JSPromise<JSFloat32Array> _classify(JSFloat32Array waveform);
@JS('guardianAudioClassifier.dispose')
external void _dispose();

class YamnetWebClassifier implements AudioClassifier {
  AudioClassifierStatus _status = AudioClassifierStatus.notInitialized;
  Future<void>? _initializing;
  int _generation = 0;

  @override
  bool get isInitialized => _status == AudioClassifierStatus.ready;

  @override
  AudioClassifierStatus get status => _status;

  @override
  Future<void> initialize() {
    if (isInitialized) return Future.value();
    return _initializing ??= _load().whenComplete(() => _initializing = null);
  }

  Future<void> _load() async {
    final generation = _generation;
    _status = AudioClassifierStatus.initializing;
    try {
      await _initialize().toDart;
      if (generation == _generation) _status = AudioClassifierStatus.ready;
    } catch (error) {
      if (generation == _generation) _status = AudioClassifierStatus.error;
      debugPrint('Local web audio unavailable; using server fallback: $error');
    }
  }

  @override
  Future<List<OnDeviceClassificationResult>> classify(
      List<int> pcm16Bytes) async {
    if (!isInitialized || pcm16Bytes.length < 31200) return [];
    final generation = _generation;
    try {
      final bytes = ByteData.sublistView(Uint8List.fromList(pcm16Bytes));
      final waveform = Float32List(pcm16Bytes.length ~/ 2);
      for (var i = 0; i < waveform.length; i++) {
        waveform[i] = bytes.getInt16(i * 2, Endian.little) / 32768;
      }
      final scores = (await _classify(waveform.toJS).toDart).toDart;
      if (generation != _generation) return [];
      final results = <OnDeviceClassificationResult>[];
      for (final entry in kAudioSetMapping.entries) {
        final score = scores[entry.key];
        if (score.isFinite && score >= .30) {
          results.add(OnDeviceClassificationResult(
              eventType: entry.value,
              labelName:
                  entry.key == 11 ? 'Screaming' : 'AudioSet_${entry.key}',
              confidence: score,
              classIndex: entry.key));
        }
      }
      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      return results;
    } catch (error) {
      if (generation == _generation) _status = AudioClassifierStatus.error;
      debugPrint('Local web inference failed; using server fallback: $error');
      return [];
    }
  }

  @override
  void dispose() {
    _generation++;
    _dispose();
    _status = AudioClassifierStatus.notInitialized;
  }
}

AudioClassifier createAudioClassifier() => YamnetWebClassifier();
