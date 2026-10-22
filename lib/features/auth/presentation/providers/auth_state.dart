/// ============================================================================
/// FILE: lib/features/auth/presentation/providers/auth_state.dart
/// MODULE: Auth - Presentation State
/// ROLE:
///   Quản lý trạng thái xác thực: Chưa đăng nhập, Đang đăng nhập, Đã đăng nhập.
/// ============================================================================

import '../../domain/entities/user_entity.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.user,
  });

  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final UserEntity? user;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    UserEntity? user,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      user: clearUser ? null : (user ?? this.user),
    );
  }
}
