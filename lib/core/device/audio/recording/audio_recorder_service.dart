/// Audio Recorder Service with platform audio recording
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import 'ring_buffer.dart';

/// Audio recorder state
enum AudioRecorderState {
  idle,
  recording,
  paused,
  stopped,
  error,
}

/// Configuration for audio recorder
class AudioRecorderConfig {
  /// Sample rate in Hz
  final int sampleRate;

  /// Number of channels
  final int numChannels;

  /// Bit rate for encoding
  final int bitRate;

  /// Chunk duration in milliseconds (for streaming)
  final int chunkDurationMs;

  const AudioRecorderConfig({
    this.sampleRate = 16000,
    this.numChannels = 1,
    this.bitRate = 128000,
    this.chunkDurationMs = 100,
  });
}

/// Audio recorder service that provides chunks to ring buffer
///
/// Uses the `record` package for cross-platform audio recording.
class AudioRecorderService {
  final AudioRecorderConfig config;
  final AudioRecorder _recorder;
  final RingBuffer _ringBuffer;
  Timer? _amplitudeTimer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<Uint8List>? _streamSubscription;

  AudioRecorderState _state = AudioRecorderState.idle;
  String? _lastError;

  /// Callback for audio chunks (for streaming/clipping)
  void Function(Uint8List chunk)? onAudioChunk;

  AudioRecorderService({
    AudioRecorderConfig? config,
    RingBuffer? ringBuffer,
  })  : config = config ?? const AudioRecorderConfig(),
        _recorder = AudioRecorder(),
        _ringBuffer = ringBuffer ??
            RingBuffer(
              config: RingBufferConfig(
                sampleRate: config?.sampleRate ?? 16000,
                maxDurationSeconds: 10.0,
              ),
            );

  /// Get the ring buffer for clip assembly
  RingBuffer get ringBuffer => _ringBuffer;

  /// Current state
  AudioRecorderState get state => _state;

  /// Last error message
  String? get lastError => _lastError;

  /// Whether recorder is currently active
  bool get isRecording => _state == AudioRecorderState.recording;

  /// Check if recorder is available on this platform
  Future<bool> isAvailable() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      debugPrint('AudioRecorderService: isAvailable error - $e');
      return false;
    }
  }

  /// Start recording with streaming to ring buffer
  /// NOTE: Must call after permission is granted
  Future<bool> start() async {
    if (_state == AudioRecorderState.recording) {
      return true; // Already recording
    }

    try {
      // Check permission
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _state = AudioRecorderState.error;
        _lastError = 'Microphone permission not granted';
        debugPrint('AudioRecorderService: Permission denied');
        return false;
      }

      // Configure recorder for PCM streaming mode
      final recordConfig = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: config.sampleRate,
        numChannels: config.numChannels,
        bitRate: config.bitRate,
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
      );

      _ringBuffer.clear();
      // Start streaming PCM chunks into memory ring buffer
      final stream = await _recorder.startStream(recordConfig);
      await _streamSubscription?.cancel();
      _streamSubscription = stream.listen(
        (chunk) {
          writeToBuffer(chunk);
          onAudioChunk?.call(chunk);
        },
        onError: (Object err) {
          _state = AudioRecorderState.error;
          _lastError = err.toString();
          debugPrint('AudioRecorderService stream error: $err');
        },
      );

      _state = AudioRecorderState.recording;
      _lastError = null;

      // Start monitoring amplitude for activity detection
      _startAmplitudeMonitoring();

      return true;
    } catch (e) {
      _state = AudioRecorderState.error;
      _lastError = e.toString();
      debugPrint('AudioRecorderService: Failed to start - $e');
      return false;
    }
  }

  /// Start monitoring amplitude for chunk detection
  void _startAmplitudeMonitoring() {
    _amplitudeTimer?.cancel();

    // Sample amplitude at regular intervals
    _amplitudeTimer = Timer.periodic(
      Duration(milliseconds: config.chunkDurationMs),
      (timer) async {
        if (_state != AudioRecorderState.recording) {
          timer.cancel();
          return;
        }

        try {
          await _recorder.getAmplitude();
          // amplitude.current is in dB, typically -160 to 0
          // We use this for activity detection in the detection service
        } catch (e) {
          debugPrint('AudioRecorderService: Amplitude error - $e');
        }
      },
    );
  }

  /// Write audio data to ring buffer
  /// Called from audio callback with raw PCM data
  void writeToBuffer(Uint8List audioData) {
    if (_state != AudioRecorderState.recording) return;
    _ringBuffer.write(audioData);
  }

  /// Take snapshot of pre-event audio (raw PCM)
  Uint8List takeSnapshot() {
    return _ringBuffer.takeSnapshot();
  }

  /// Take snapshot and encode directly to valid WAV format (RIFF header)
  Uint8List takeWavSnapshot() {
    var pcmData = _ringBuffer.takeSnapshot();
    if (pcmData.isEmpty) {
      // Fallback 0.5s of silence so clip is never 0-bytes
      pcmData = Uint8List(config.sampleRate * config.numChannels * 2 ~/ 2);
    }
    return encodeToWav(
      pcmData,
      sampleRate: config.sampleRate,
      numChannels: config.numChannels,
    );
  }

  /// Encode raw PCM 16-bit data to standard WAV bytes
  static Uint8List encodeToWav(
    Uint8List pcmData, {
    int sampleRate = 16000,
    int numChannels = 1,
  }) {
    final byteData = ByteData(44);
    // RIFF header
    byteData.setUint8(0, 0x52); // R
    byteData.setUint8(1, 0x49); // I
    byteData.setUint8(2, 0x46); // F
    byteData.setUint8(3, 0x46); // F
    byteData.setUint32(4, 36 + pcmData.length, Endian.little); // File size - 8
    byteData.setUint8(8, 0x57); // W
    byteData.setUint8(9, 0x41); // A
    byteData.setUint8(10, 0x56); // V
    byteData.setUint8(11, 0x45); // E
    // fmt chunk
    byteData.setUint8(12, 0x66); // f
    byteData.setUint8(13, 0x6D); // m
    byteData.setUint8(14, 0x74); // t
    byteData.setUint8(15, 0x20); // space
    byteData.setUint32(16, 16, Endian.little); // Chunk size
    byteData.setUint16(20, 1, Endian.little); // Audio format (1 = PCM)
    byteData.setUint16(22, numChannels, Endian.little); // Channels
    byteData.setUint32(24, sampleRate, Endian.little); // Sample rate
    byteData.setUint32(
      28,
      sampleRate * numChannels * 2,
      Endian.little,
    ); // Byte rate (sampleRate * numChannels * bitsPerSample/8)
    byteData.setUint16(
      32,
      numChannels * 2,
      Endian.little,
    ); // Block align (numChannels * bitsPerSample/8)
    byteData.setUint16(34, 16, Endian.little); // Bits per sample
    // data chunk
    byteData.setUint8(36, 0x64); // d
    byteData.setUint8(37, 0x61); // a
    byteData.setUint8(38, 0x74); // t
    byteData.setUint8(39, 0x61); // a
    byteData.setUint32(40, pcmData.length, Endian.little); // Data size

    final header = byteData.buffer.asUint8List();
    return Uint8List.fromList([...header, ...pcmData]);
  }

  /// Get current buffer duration
  double get bufferDuration => _ringBuffer.durationSeconds;

  /// Check if buffer has enough data
  bool hasEnoughData(double minSeconds) => _ringBuffer.hasAtLeast(minSeconds);

  /// Get ring buffer stats
  RingBufferStats get bufferStats => _ringBuffer.stats;

  /// Get current amplitude from recorder
  Future<Amplitude> getAmplitude() async {
    return await _recorder.getAmplitude();
  }

  /// Stop recording
  Future<void> stop() async {
    if (_state != AudioRecorderState.recording &&
        _state != AudioRecorderState.paused) {
      return;
    }

    try {
      _amplitudeTimer?.cancel();
      await _amplitudeSubscription?.cancel();
      await _streamSubscription?.cancel();
      _streamSubscription = null;
      await _recorder.stop();
      _state = AudioRecorderState.stopped;
    } catch (e) {
      _state = AudioRecorderState.error;
      _lastError = e.toString();
      debugPrint('AudioRecorderService: Failed to stop - $e');
    }
  }

  /// Pause recording (if supported)
  Future<void> pause() async {
    if (_state != AudioRecorderState.recording) return;

    try {
      await _recorder.pause();
      _amplitudeTimer?.cancel();
      _state = AudioRecorderState.paused;
    } catch (e) {
      debugPrint('AudioRecorderService: Pause not supported - $e');
    }
  }

  /// Resume recording
  Future<void> resume() async {
    if (_state != AudioRecorderState.paused) return;

    try {
      await _recorder.resume();
      _state = AudioRecorderState.recording;
      _startAmplitudeMonitoring();
    } catch (e) {
      debugPrint('AudioRecorderService: Resume failed - $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stop();
    _amplitudeTimer?.cancel();
    await _amplitudeSubscription?.cancel();
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await _recorder.dispose();
  }

  /// Get stream status for debugging
  Map<String, dynamic> getStatus() {
    return {
      'state': _state.name,
      'bufferDuration': bufferDuration,
      'bufferStats': bufferStats.toString(),
      'lastError': _lastError,
      'config': {
        'sampleRate': config.sampleRate,
        'numChannels': config.numChannels,
      },
    };
  }
}
