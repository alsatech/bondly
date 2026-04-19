import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/register_request.dart';
import '../../data/models/user_model.dart';
import '../../domain/auth_failure.dart';
import 'auth_providers.dart';

// ---------------------------------------------------------------------------
// Auth State
// ---------------------------------------------------------------------------

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserModel user;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.failure);
  final AuthFailure failure;
}

// ---------------------------------------------------------------------------
// AuthNotifier
// ---------------------------------------------------------------------------

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    try {
      final storage = ref.read(secureStorageProvider);
      final hasToken = await storage.hasValidToken();

      if (!hasToken) {
        state = const AuthUnauthenticated();
        return;
      }

      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getMe();
      state = AuthAuthenticated(user);
    } on AuthFailure {
      state = const AuthUnauthenticated();
      // Clear invalid tokens
      final storage = ref.read(secureStorageProvider);
      await storage.clearTokens();
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      state = AuthAuthenticated(user);
    } on AuthFailure catch (f) {
      state = AuthError(f);
    } catch (_) {
      state = const AuthError(UnknownFailure());
    }
  }

  Future<void> register(RegisterRequest request) async {
    state = const AuthLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(request);
      state = AuthAuthenticated(user);
    } on AuthFailure catch (f) {
      state = AuthError(f);
    } catch (_) {
      state = const AuthError(UnknownFailure());
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Convenience provider: resolves to the current user or null.
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState is AuthAuthenticated ? authState.user : null;
});
