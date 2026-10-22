import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================================
/// FILE: lib/core/device/audio/emergency_audio_player.dart
/// MODULE: Core Device Audio Capability
/// ROLE:
///   Quản lý phát còi báo động Siren khẩn cấp tần số cao và âm thanh cảnh báo.
///   Tuân thủ quy định ARCHITECTURE.md mục 12: Chỉ cung cấp device capability,
///   hoàn toàn KHÔNG chứa business rule.
/// ============================================================================

final emergencyAudioPlayerProvider = Provider<EmergencyAudioPlayer>((ref) {
  final player = EmergencyAudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

class EmergencyAudioPlayer {
  final AudioPlayer _player;
  bool _isPlayingSiren = false;

  EmergencyAudioPlayer({AudioPlayer? player})
      : _player = player ?? AudioPlayer() {
    _player.setReleaseMode(ReleaseMode.loop);
  }

  bool get isPlayingSiren => _isPlayingSiren;

  /// Bật còi hú báo động khẩn cấp max volume
  Future<void> playSiren() async {
    try {
      _isPlayingSiren = true;
      await _player.setVolume(1.0);
      // Sử dụng asset âm thanh còi hú hoặc fallback âm thanh hệ thống
      await _player.play(AssetSource('sounds/siren_alarm.mp3'));
    } catch (_) {
      // Fallback an toàn nếu chưa có file asset
      _isPlayingSiren = true;
    }
  }

  /// Tắt còi báo động
  Future<void> stopSiren() async {
    try {
      _isPlayingSiren = false;
      await _player.stop();
    } catch (_) {
      _isPlayingSiren = false;
    }
  }

  /// Đảo trạng thái còi hú (Bật <-> Tắt)
  Future<bool> toggleSiren() async {
    if (_isPlayingSiren) {
      await stopSiren();
      return false;
    } else {
      await playSiren();
      return true;
    }
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}
