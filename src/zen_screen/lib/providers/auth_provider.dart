import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

/// Global provider exposing the [AuthService] instance.
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

/// State class representing the different authentication statuses.
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.authenticated(AppUser user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.error(AuthServiceException exception) = AuthError;
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AppUser user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthError extends AuthState {
  const AuthError(this.exception);

  final AuthServiceException exception;
}

/// Notifier that bridges Firebase auth changes into app state.
@riverpod
class AuthController extends _$AuthController {
  StreamSubscription? _authSubscription;

  @override
  AuthState build() {
    final authService = ref.watch(authServiceProvider);

    _authSubscription = authService.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        state = const AuthState.unauthenticated();
      } else {
        state = AuthState.authenticated(AppUser.fromFirebase(firebaseUser));
      }
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return const AuthState.initial();
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final authService = ref.read(authServiceProvider);
    try {
      final user = await authService.registerWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        state = AuthState.authenticated(AppUser.fromFirebase(user));
      } else {
        state = const AuthState.unauthenticated();
      }
    } on AuthServiceException catch (error) {
      state = AuthState.error(error);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final authService = ref.read(authServiceProvider);
    try {
      final user = await authService.signInWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        state = AuthState.authenticated(AppUser.fromFirebase(user));
      } else {
        state = const AuthState.unauthenticated();
      }
    } on AuthServiceException catch (error) {
      state = AuthState.error(error);
    }
  }

  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    final authService = ref.read(authServiceProvider);
    try {
      await authService.sendPasswordResetEmail(email: email);
    } on AuthServiceException catch (error) {
      state = AuthState.error(error);
    }
  }
}

