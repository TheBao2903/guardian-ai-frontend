import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/device/flashlight/flashlight_controller.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/providers/auth_state.dart';

/// Covers restored sessions, token expiry, account changes and app lifecycle.
class FlashlightSessionScope extends ConsumerStatefulWidget {
  const FlashlightSessionScope({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<FlashlightSessionScope> createState() =>
      _FlashlightSessionScopeState();
}

class _FlashlightSessionScopeState extends ConsumerState<FlashlightSessionScope>
    with WidgetsBindingObserver {
  late final ProviderSubscription<AuthState> _auth;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth = ref.listenManual(authControllerProvider, (previous, next) {
      if (previous?.user?.uid != next.user?.uid || previous == null) {
        final userId = next.user?.uid;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && ref.read(authControllerProvider).user?.uid == userId) {
            unawaited(
                ref.read(flashlightControllerProvider).beginSession(userId));
          }
        });
      }
    }, fireImmediately: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final light = ref.read(flashlightControllerProvider);
    if (state == AppLifecycleState.resumed) {
      unawaited(light.refreshPermission());
    } else if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(light.turnOff());
    }
  }

  @override
  void dispose() {
    _auth.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
