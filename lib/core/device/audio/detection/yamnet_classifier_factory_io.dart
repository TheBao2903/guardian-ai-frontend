/// Native (Android, iOS, Desktop) AudioClassifier implementation with tflite_flutter
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:guardian_ai/core/device/audio/danger_audio_manager.dart';
import 'yamnet_classifier.dart';

class YamnetIoClassifier implements AudioClassifier {
  Interpreter? _interpreter;
  final Map<int, String> _classNames = {};
  AudioClassifierStatus _status = AudioClassifierStatus.notInitialized;
  Completer<void>? _initCompleter;

  @override
  bool get isInitialized => _status == AudioClassifierStatus.ready;

  @override
  AudioClassifierStatus get status => _status;

  @override
  Future<void> initialize() async {
    if (_status == AudioClassifierStatus.ready) return;
    if (_status == AudioClassifierStatus.initializing &&
        _initCompleter != null) {
      return _initCompleter!.future;
    }

    _status = AudioClassifierStatus.initializing;
    _initCompleter = Completer<void>();

    try {
      // 1. Tải danh mục nhãn từ CSV asset (parser an toàn với trường có dấu phẩy trong ngoặc kép)
      final csvString =
          await rootBundle.loadString('assets/models/yamnet_class_map.csv');
      final lines = const LineSplitter().convert(csvString);
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final firstComma = line.indexOf(',');
        if (firstComma == -1) continue;
        final secondComma = line.indexOf(',', firstComma + 1);
        if (secondComma == -1) continue;

        final idxStr = line.substring(0, firstComma).trim();
        final idx = int.tryParse(idxStr);
        if (idx == null) continue;

        var name = line.substring(secondComma + 1).trim();
        if (name.startsWith('"') && name.endsWith('"') && name.length >= 2) {
          name = name.substring(1, name.length - 1);
        }
        _classNames[idx] = name;
      }

      // 2. Khởi tạo TensorFlow Lite Interpreter
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        'assets/models/yamnet.tflite',
        options: options,
      );

      // 3. Khởi động Warm-up Inference (cấp phát trước bộ đệm tensor)
      final dummyInput = List<double>.filled(15600, 0.0);
      final dummyOutput = List.generate(1, (_) => List.filled(521, 0.0));
      _interpreter!.run(dummyInput, dummyOutput);

      _status = AudioClassifierStatus.ready;
      _initCompleter!.complete();
      debugPrint(
          'YamnetTfliteClassifier: Preload & Warm-up mô hình YAMNet On-device thành công (${_classNames.length} classes)');
    } catch (e) {
      _status = AudioClassifierStatus.error;
      _initCompleter!.complete();
      debugPrint('YamnetTfliteClassifier: Lỗi khởi tạo mô hình TFLite: $e');
    }
  }

  @override
  Future<List<OnDeviceClassificationResult>> classify(
      List<int> pcm16Bytes) async {
    if (!isInitialized || _interpreter == null) {
      return [];
    }

    if (pcm16Bytes.length < 31200) {
      return [];
    }

    try {
      final byteData = ByteData.sublistView(Uint8List.fromList(pcm16Bytes));
      final totalSamples = pcm16Bytes.length ~/ 2;

      // Inspect overlapping frames so a short event between ticks is retained.
      final starts = <int>{};
      for (var start = 0; start + 15600 <= totalSamples; start += 7680) {
        starts.add(start);
      }
      starts.add(totalSamples - 15600);
      final scores = List<double>.filled(521, 0.0);
      for (final start in starts) {
        final input = List<double>.generate(15600,
            (i) => byteData.getInt16((start + i) * 2, Endian.little) / 32768.0);
        final output = List.generate(1, (_) => List.filled(521, 0.0));
        _interpreter!.run(input, output);
        for (var i = 0; i < scores.length; i++) {
          if (output[0][i] > scores[i]) scores[i] = output[0][i];
        }
      }

      // DIAGNOSTIC LOGGING: In 5 nhãn có xác suất cao nhất phục vụ chẩn đoán
      if (kDebugMode) {
        final topIndices = List<int>.generate(scores.length, (i) => i)
          ..sort((a, b) => scores[b].compareTo(scores[a]));
        final top5Str = topIndices.take(5).map((idx) {
          final label = _classNames[idx] ?? 'Class_$idx';
          return '$label: ${(scores[idx] * 100).toStringAsFixed(1)}%';
        }).join(', ');
        debugPrint('[YAMNet On-Device Top-5] $top5Str');
      }

      final List<OnDeviceClassificationResult> results = [];
      for (final entry in kAudioSetMapping.entries) {
        final classIdx = entry.key;
        final eventType = entry.value;

        if (classIdx >= scores.length) continue;
        final score = scores[classIdx];

        final threshold = (eventType == DangerEventType.scream ||
                eventType == DangerEventType.gunshot)
            ? 0.30
            : 0.40;

        if (score >= threshold) {
          results.add(
            OnDeviceClassificationResult(
              eventType: eventType,
              labelName: _classNames[classIdx] ?? 'AudioSet_$classIdx',
              confidence: score,
              classIndex: classIdx,
            ),
          );
        }
      }

      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      return results;
    } catch (e) {
      _status = AudioClassifierStatus.error;
      debugPrint('YamnetTfliteClassifier: Lỗi suy luận On-device: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _status = AudioClassifierStatus.notInitialized;
    _initCompleter = null;
  }
}

AudioClassifier createAudioClassifier() => YamnetIoClassifier();
