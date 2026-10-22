import 'dart:math' as math;
import 'dart:typed_data';

import '../danger_audio_manager.dart';

/// Recent, overlapping 2s windows of mono PCM16 at 16 kHz.
class AudioAnalysisInput {
  final Uint8List pcm;
  final double peakDbfs;
  final int endSample;
  final DateTime capturedAt;

  AudioAnalysisInput._(
      this.pcm, this.peakDbfs, this.endSample, this.capturedAt);

  static AudioAnalysisInput? fromPcm(Uint8List bytes,
      {int endSample = 0, DateTime? capturedAt}) {
    if (bytes.length < 31200) return null;
    final end = bytes.length - bytes.length % 2;
    final pcm = Uint8List.sublistView(bytes, math.max(0, end - 64000), end);
    final samples = ByteData.sublistView(pcm);
    var peak = 0;
    for (var i = 0; i < pcm.length; i += 2) {
      peak = math.max(peak, samples.getInt16(i, Endian.little).abs());
    }
    if (peak == 0) return null;
    return AudioAnalysisInput._(pcm, 20 * math.log(peak / 32768) / math.ln10,
        endSample, capturedAt ?? DateTime.now());
  }
}

/// A risk flag without a supported, scored model signal cannot identify a sound.
DangerDetectionResult parseBackendAudioResult(Map<dynamic, dynamic> data,
    {required double amplitude}) {
  const types = {
    'SCREAM': DangerEventType.scream,
    'CALL_FOR_HELP': DangerEventType.distressCry,
    'DISTRESS_CRY': DangerEventType.distressCry,
    'GUNSHOT': DangerEventType.gunshot,
  };
  // Backend cooldown describes its risk evaluator, not an SOS sent to the
  // user. Local event cooldown and pending-alert state prevent duplicate UI.

  final signals = data['signals'];
  if (signals is! List) return DangerDetectionResult.none();
  DangerDetectionResult result = DangerDetectionResult.none();
  for (final signal in signals) {
    if (signal is! Map) continue;
    final type = types[signal['event_type']];
    final confidence = signal['confidence'];
    if (type == null || confidence is! num) continue;
    final score = confidence.toDouble();
    final threshold = type == DangerEventType.distressCry ? 0.40 : 0.30;
    if (!score.isFinite ||
        score < threshold ||
        score > 1 ||
        score <= result.confidence) {
      continue;
    }
    result = DangerDetectionResult(
      detected: true,
      eventType: type,
      confidence: score,
      timestamp: DateTime.now(),
      amplitude: amplitude,
    );
  }
  return result;
}
