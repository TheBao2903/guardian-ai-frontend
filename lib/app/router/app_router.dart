import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/home_shell_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/safety_check/presentation/screens/safety_check_screen.dart';
import '../../features/sos/presentation/providers/sos_controller.dart';
import '../../features/sos/presentation/providers/sos_state.dart';
import '../../features/sos/presentation/screens/active_sos_screen.dart';
import '../../features/sos/presentation/screens/sos_confirmation_screen.dart';
import '../../features/home/presentation/widgets/danger_alert_sheet.dart';
import 'route_names.dart';

/// ============================================================================
/// FILE: lib/app/router/app_router.dart
/// MODULE: GoRouter Global Navigation Configuration
/// ROLE:
///   1. Quản lý trạng thái xác thực (Auth Guard Redirect: Login -> Home).
///   2. Quản lý chuyển hướng khẩn cấp SOS (Auto redirect to /active-sos khi AI scream / SOS kích hoạt).
///   3. Định nghĩa StatefulShellRoute.indexedStack cho 4 Tab chính:
///      - Tab 0: Home (Trang chủ)
///      - Tab 1: Safety Check (Hẹn giờ bảo vệ)
///      - Tab 2: Contacts (10 Người thân khẩn cấp)
///      - Tab 3: Profile (Hồ sơ y tế, Đổi PIN SOS, Cài đặt & Đăng xuất)
///   4. Định nghĩa các Fullscreen Routes: Active SOS, Login, Register.
/// ============================================================================

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _safetyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'safetyNav');
final _contactsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'contactsNav');
final _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profileNav');

/// Notifier lắng nghe sự thay đổi của authController và sosController để GoRouter tự động redirect
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated ||
            previous?.isInitialized != next.isInitialized) {
          notifyListeners();
        }
      },
    );

    ref.listen<SosState>(
      sosControllerProvider,
      (previous, next) {
        if (previous?.isSosActive != next.isSosActive) {
          if (next.isSosActive) {
            // Đóng tất cả dialog / modal bottom sheet đang mở để màn hình Active SOS hiển thị trọn vẹn
            rootNavigatorKey.currentState
                ?.popUntil((route) => route is PageRoute);
          }
          notifyListeners();
        }
      },
    );

    ref.listen<DangerAlertState>(dangerAlertProvider, (previous, next) {
      if (previous?.isShowing != next.isShowing) notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.login,
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register;

      // Nếu chưa xác thực và không ở các màn Auth -> chuyển về Login
      if (!authState.isAuthenticated && !isAuthRoute) {
        return RouteNames.login;
      }

      // Nếu đã xác thực mà lại ở màn Login/Register -> chuyển vào Home
      if (authState.isAuthenticated && isAuthRoute) {
        return RouteNames.home;
      }

      if (authState.isAuthenticated) {
        return resolveSosRedirect(
          state.uri,
          activeSos: ref.read(sosControllerProvider).isSosActive,
          pendingAlert: ref.read(dangerAlertProvider).isShowing,
        );
      }

      return null;
    },
    routes: [
      // 1. Fullscreen Auth Routes (Không hiển thị Bottom Navigation)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 2. Stateful Shell Route (4 Tabs Bottom Navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home (Trang chủ)
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: Safety Check (Hẹn giờ bảo vệ)
          StatefulShellBranch(
            navigatorKey: _safetyNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.safetyCheck,
                builder: (context, state) => const SafetyCheckScreen(),
              ),
            ],
          ),

          // Branch 2: Contacts (Danh bạ 10 người thân)
          StatefulShellBranch(
            navigatorKey: _contactsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.contacts,
                builder: (context, state) => const ContactsScreen(),
              ),
            ],
          ),

          // Branch 3: Profile (Tài khoản, Y tế & Cài đặt)
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.sosConfirmation,
        builder: (context, state) => const SosConfirmationScreen(),
      ),

      // 3. Fullscreen SOS Alert Route (Đè lên toàn bộ app)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.activeSos,
        builder: (context, state) => const ActiveSosScreen(),
      ),
    ],
  );
});

/// Shared by the router and tests of the pending -> active SOS transition.
String? resolveSosRedirect(Uri uri,
    {required bool activeSos, required bool pendingAlert}) {
  if (activeSos) {
    return uri.path == RouteNames.activeSos ? null : RouteNames.activeSos;
  }
  if (pendingAlert) {
    if (uri.path == RouteNames.sosConfirmation) return null;
    return Uri(
        path: RouteNames.sosConfirmation,
        queryParameters: {'returnTo': uri.path}).toString();
  }
  if (uri.path == RouteNames.sosConfirmation) {
    final returnTo = uri.queryParameters['returnTo'];
    const allowed = {
      RouteNames.home,
      RouteNames.safetyCheck,
      RouteNames.contacts,
      RouteNames.profile
    };
    return allowed.contains(returnTo) ? returnTo : RouteNames.home;
  }
  return uri.path == RouteNames.activeSos ? RouteNames.home : null;
}
