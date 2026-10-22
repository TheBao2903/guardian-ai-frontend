/// Ring Buffer for audio pre-roll storage
library;

import 'dart:typed_data';

/// Configuration for ring buffer
class RingBufferConfig {
  /// Sample rate in Hz (default: 16000)
  final int sampleRate;

  /// Maximum duration to keep in seconds (default: 5.0)
  final double maxDurationSeconds;

  /// Number of channels (default: 1 = mono)
  final int channels;

  /// Bytes per sample (default: 2 = 16-bit)
  final int bytesPerSample;

  const RingBufferConfig({
    this.sampleRate = 16000,
    this.maxDurationSeconds = 5.0,
    this.channels = 1,
    this.bytesPerSample = 2,
  });

  /// Total number of samples that fit in buffer
  int get maxSamples => (sampleRate * maxDurationSeconds).ceil();

  /// Total bytes capacity
  int get capacityBytes => maxSamples * channels * bytesPerSample;
}

/// In-memory circular buffer for audio pre-roll
///
/// Usage:
/// ```dart
/// final buffer = RingBuffer(config: RingBufferConfig(maxDurationSeconds: 5.0));
///
/// // In audio callback, write chunks:
/// buffer.write(audioChunkBytes);
///
/// // When event detected, take snapshot:
/// final clip = buffer.takeSnapshot();
/// ```
class RingBuffer {
  final RingBufferConfig config;
  final Uint8List _buffer;

  /// Write position (next write index in samples)
  int _writePosition = 0;

  /// Number of valid samples in buffer (may be < capacity before buffer is full)
  int _validSamples = 0;

  /// Whether buffer has been filled at least once
  bool _hasWrapped = false;

  RingBuffer({RingBufferConfig? config})
      : config = config ?? const RingBufferConfig(),
        _buffer = Uint8List(
          (config ?? const RingBufferConfig()).capacityBytes,
        );

  /// Write audio data to buffer
  /// Data is interleaved PCM: L0 R0 L1 R1... for stereo, or just L0 L1 L2... for mono
  void write(Uint8List data) {
    final samplesPerChunk =
        data.length ~/ (config.channels * config.bytesPerSample);
    if (samplesPerChunk == 0) return;

    for (int i = 0; i < samplesPerChunk; i++) {
      // Copy sample-by-sample for wrap-around handling
      final sampleOffset = i * config.channels * config.bytesPerSample;
      for (int c = 0; c < config.channels * config.bytesPerSample; c++) {
        _buffer[(_writePosition * config.channels * config.bytesPerSample + c) %
            _buffer.length] = data[sampleOffset + c];
      }
      _writePosition = (_writePosition + 1) % config.maxSamples;
      if (_writePosition == 0) {
        _hasWrapped = true;
      }
      if (_validSamples < config.maxSamples) {
        _validSamples++;
      }
    }
  }

  /// Take snapshot of current buffer
  /// Returns copy of audio data from buffer
  Uint8List takeSnapshot() {
    if (_validSamples == 0) {
      return Uint8List(0);
    }

    final result =
        Uint8List(_validSamples * config.channels * config.bytesPerSample);
    final bytesPerSample_ = config.channels * config.bytesPerSample;

    // Calculate starting position (oldest valid sample)
    int startPos;
    if (_hasWrapped || _validSamples < config.maxSamples) {
      // Buffer has wrapped or not yet full
      startPos = _writePosition >= _validSamples
          ? _writePosition - _validSamples
          : config.maxSamples - (_validSamples - _writePosition);
    } else {
      // Buffer is full, start from write position
      startPos = _writePosition;
    }

    // Copy data from circular buffer
    int resultOffset = 0;
    int remainingSamples = _validSamples;

    while (remainingSamples > 0) {
      final copySamples = remainingSamples > config.maxSamples - startPos
          ? config.maxSamples - startPos
          : remainingSamples;

      final dstOffset = resultOffset;
      final length = copySamples * bytesPerSample_;
      result.setRange(
        dstOffset,
        dstOffset + length,
        _buffer,
        startPos * bytesPerSample_,
      );

      resultOffset += length;
      remainingSamples -= copySamples;
      startPos = (startPos + copySamples) % config.maxSamples;
    }

    return result;
  }

  /// Get duration of valid audio in buffer
  double get durationSeconds {
    return _validSamples / config.sampleRate;
  }

  /// Check if buffer is ready (has at least minSeconds of data)
  bool hasAtLeast(double minSeconds) {
    return _validSamples >= (minSeconds * config.sampleRate).ceil();
  }

  /// Check if buffer has been filled at least once
  bool get isReady => _hasWrapped || _validSamples >= config.maxSamples * 0.5;

  /// Clear buffer
  void clear() {
    _writePosition = 0;
    _validSamples = 0;
    _hasWrapped = false;
  }

  /// Get statistics for debugging
  RingBufferStats get stats => RingBufferStats(
        validSamples: _validSamples,
        capacitySamples: config.maxSamples,
        durationSeconds: durationSeconds,
        isReady: isReady,
        hasWrapped: _hasWrapped,
      );
}

/// Statistics for ring buffer
class RingBufferStats {
  final int validSamples;
  final int capacitySamples;
  final double durationSeconds;
  final bool isReady;
  final bool hasWrapped;

  const RingBufferStats({
    required this.validSamples,
    required this.capacitySamples,
    required this.durationSeconds,
    required this.isReady,
    required this.hasWrapped,
  });

  double get fillPercentage =>
      capacitySamples > 0 ? (validSamples / capacitySamples) * 100 : 0;

  @override
  String toString() {
    return 'RingBufferStats(validSamples: $validSamples, capacity: $capacitySamples, '
        'duration: ${durationSeconds.toStringAsFixed(2)}s, '
        'fill: ${fillPercentage.toStringAsFixed(1)}%, '
        'ready: $isReady, wrapped: $hasWrapped)';
  }
}
