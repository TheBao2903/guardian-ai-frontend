/// Cooldown Manager - Prevents Alert Storm
library;

/// Manages cooldowns between detection events to prevent alert storms
///
/// When an event is detected, subsequent detections of the same type
/// are suppressed for a cooldown period. This prevents:
/// - Multiple alerts for the same event
/// - Resource exhaustion from rapid detection
/// - User notification fatigue
class CooldownManager {
  /// Cooldown duration per event type (in milliseconds)
  final Map<String, int> _cooldowns;

  /// Last triggered time per event type
  final Map<String, DateTime> _lastTriggered;

  /// Default cooldown in milliseconds
  final int defaultCooldownMs;

  /// Global cooldown (prevents ANY event from triggering)
  DateTime? _globalCooldownEnd;

  CooldownManager({
    Map<String, int>? cooldowns,
    this.defaultCooldownMs = 10000, // 10 seconds default
  })  : _cooldowns = cooldowns ?? {},
        _lastTriggered = {};

  /// Check if an event type is in cooldown
  bool isInCooldown(String eventType) {
    // Check global cooldown first
    if (_globalCooldownEnd != null &&
        DateTime.now().isBefore(_globalCooldownEnd!)) {
      return true;
    }

    final lastTriggered = _lastTriggered[eventType];
    if (lastTriggered == null) {
      return false;
    }

    final cooldownDuration = _cooldowns[eventType] ?? defaultCooldownMs;
    final cooldownEnd =
        lastTriggered.add(Duration(milliseconds: cooldownDuration));

    return DateTime.now().isBefore(cooldownEnd);
  }

  /// Get remaining cooldown time for an event type (in milliseconds)
  int getRemainingCooldown(String eventType) {
    final lastTriggered = _lastTriggered[eventType];
    if (lastTriggered == null) {
      return 0;
    }

    final cooldownDuration = _cooldowns[eventType] ?? defaultCooldownMs;
    final cooldownEnd =
        lastTriggered.add(Duration(milliseconds: cooldownDuration));
    final remaining = cooldownEnd.difference(DateTime.now()).inMilliseconds;

    return remaining > 0 ? remaining : 0;
  }

  /// Trigger an event (starts its cooldown)
  void trigger(String eventType) {
    _lastTriggered[eventType] = DateTime.now();
  }

  /// Set cooldown duration for an event type
  void setCooldown(String eventType, int durationMs) {
    _cooldowns[eventType] = durationMs;
  }

  /// Set global cooldown (prevents all events)
  void setGlobalCooldown(int durationMs) {
    _globalCooldownEnd = DateTime.now().add(Duration(milliseconds: durationMs));
  }

  /// Clear global cooldown
  void clearGlobalCooldown() {
    _globalCooldownEnd = null;
  }

  /// Clear cooldown for a specific event type
  void clearCooldown(String eventType) {
    _lastTriggered.remove(eventType);
  }

  /// Clear all cooldowns
  void clearAll() {
    _lastTriggered.clear();
    _globalCooldownEnd = null;
  }

  /// Get cooldown status for all event types
  Map<String, int> getCooldownStatus() {
    final status = <String, int>{};
    for (final eventType in _lastTriggered.keys) {
      final remaining = getRemainingCooldown(eventType);
      if (remaining > 0) {
        status[eventType] = remaining;
      }
    }
    return status;
  }

  /// Check if global cooldown is active
  bool get isGlobalCooldownActive =>
      _globalCooldownEnd != null &&
      DateTime.now().isBefore(_globalCooldownEnd!);

  /// Get remaining global cooldown time (in milliseconds)
  int get globalCooldownRemaining {
    if (_globalCooldownEnd == null) return 0;
    final remaining =
        _globalCooldownEnd!.difference(DateTime.now()).inMilliseconds;
    return remaining > 0 ? remaining : 0;
  }
}
