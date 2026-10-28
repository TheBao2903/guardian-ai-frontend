import 'dart:collection';
import 'dart:typed_data';

import '../recording/ring_buffer.dart';
import 'audio_analysis_input.dart';

/// Capture windows independently of network latency. A scream arriving while
/// another window is being classified must remain queued for classification.
class AudioAnalysisQueue {
  AudioAnalysisQueue(
      {this.maxPending = 4, this.maxAge = const Duration(seconds: 4)})
      : assert(maxPending > 0);

  final int maxPending;
  final Duration maxAge;
  final _buffer = RingBuffer(
    config: const RingBufferConfig(maxDurationSeconds: 2),
  );
  final _pending = Queue<AudioAnalysisInput>();
  int _bytesUntilWindow = 64000;
  int _totalBytes = 0;
  int droppedWindows = 0;
  int expiredWindows = 0;

  int get pendingCount => _pending.length;

  void add(Uint8List pcm, {DateTime? capturedAt}) {
    var offset = 0;
    final end = pcm.length - pcm.length % 2;
    while (offset < end) {
      final available = end - offset;
      final count =
          available < _bytesUntilWindow ? available : _bytesUntilWindow;
      _buffer.write(Uint8List.sublistView(pcm, offset, offset + count));
      offset += count;
      _totalBytes += count;
      _bytesUntilWindow -= count;
      if (_bytesUntilWindow == 0) {
        final input = AudioAnalysisInput.fromPcm(_buffer.takeSnapshot(),
            endSample: _totalBytes ~/ 2, capturedAt: capturedAt);
        if (input != null) {
          if (_pending.length == maxPending) {
            _pending.removeFirst();
            droppedWindows++;
          }
          _pending.add(input);
        }
        _bytesUntilWindow = 38400; // 1.2s hop with 0.8s overlap.
      }
    }
  }

  AudioAnalysisInput? takeNext({DateTime? now}) {
    final time = now ?? DateTime.now();
    while (_pending.isNotEmpty) {
      final input = _pending.removeFirst();
      if (time.difference(input.capturedAt) > maxAge) {
        expiredWindows++;
        continue;
      }
      return input;
    }
    return null;
  }

  void clear() {
    _pending.clear();
    _buffer.clear();
    _bytesUntilWindow = 64000;
    _totalBytes = 0;
    droppedWindows = 0;
    expiredWindows = 0;
  }
}
