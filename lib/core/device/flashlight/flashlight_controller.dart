import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torch_light/torch_light.dart';

/// ============================================================================
/// FILE: lib/core/device/flashlight/flashlight_controller.dart
/// MODULE: Core Device Flashlight Capability
/// ROLE:
///   Điều khiển đèn Flash camera: Bật, Tắt và Chế độ chớp nhấp nháy Strobe SOS.
///   Tuân thủ ARCHITECTURE.md: Chỉ cung cấp capability phần cứng.
/// ============================================================================

final flashlightControllerProvider = Provider<FlashlightController>((ref) {
  final controller = FlashlightController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class FlashlightController {
  bool _isTorchOn = false;
  bool _isStrobeActive = false;
  Timer? _strobeTimer;

  bool get isTorchOn => _isTorchOn;
  bool get isStrobeActive => _isStrobeActive;

  /// Bật đèn pin sáng liên tục
  Future<void> enableTorch() async {
    try {
      await TorchLight.enableTorch();
      _isTorchOn = true;
    } catch (_) {
      _isTorchOn = false;
    }
  }

  /// Tắt đèn pin
  Future<void> disableTorch() async {
    try {
      _stopStrobeTimer();
      await TorchLight.disableTorch();
      _isTorchOn = false;
      _isStrobeActive = false;
    } catch (_) {
      _isTorchOn = false;
      _isStrobeActive = false;
    }
  }

  /// Tắt toàn bộ đèn (alias cho disableTorch)
  Future<void> turnOff() => disableTorch();

  /// Bật chế độ chớp đèn nhấp nháy liên tục (Strobe SOS)
  Future<void> startStrobe({Duration interval = const Duration(milliseconds: 350)}) async {
    _isStrobeActive = true;
    _stopStrobeTimer();

    bool toggleState = false;
    _strobeTimer = Timer.periodic(interval, (timer) async {
      toggleState = !toggleState;
      try {
        if (toggleState) {
          await TorchLight.enableTorch();
        } else {
          await TorchLight.disableTorch();
        }
      } catch (_) {}
    });
  }

  /// Đảo trạng thái Strobe (Bật <-> Tắt)
  Future<bool> toggleStrobe() async {
    if (_isStrobeActive) {
      await disableTorch();
      return false;
    } else {
      await startStrobe();
      return true;
    }
  }

  void _stopStrobeTimer() {
    _strobeTimer?.cancel();
    _strobeTimer = null;
  }

  void dispose() {
    _stopStrobeTimer();
    disableTorch();
  }
}
