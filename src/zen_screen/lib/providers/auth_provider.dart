import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/app_user.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../providers/repository_providers.dart';

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

    // Check current auth state immediately
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      final appUser = AppUser.fromFirebase(currentUser);
      _ensureUserProfile(appUser);
      return AuthState.authenticated(appUser);
    }

    _authSubscription = authService.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        state = const AuthState.unauthenticated();
      } else {
        final appUser = AppUser.fromFirebase(firebaseUser);
        state = AuthState.authenticated(appUser);
        _ensureUserProfile(appUser);
      }
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return const AuthState.unauthenticated();
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
        final appUser = AppUser.fromFirebase(user);
        state = AuthState.authenticated(appUser);
        await _ensureUserProfile(appUser);
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
        final appUser = AppUser.fromFirebase(user);
        state = AuthState.authenticated(appUser);
        await _ensureUserProfile(appUser);
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

extension on AuthController {
  Future<void> _ensureUserProfile(AppUser appUser) async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final firestore = ref.read(firestoreServiceProvider);

      // If local profile exists, just ensure cloud is up to date
      final existing = await userRepo.getUserProfile(userId: appUser.id);
      final now = DateTime.now();

      final profile = existing ?? UserProfile(
        id: appUser.id,
        email: appUser.email,
        displayName: appUser.displayName?.trim().isNotEmpty == true
            ? appUser.displayName!.trim()
            : appUser.email.split('@').first,
        avatarUrl: appUser.photoUrl,
        createdAt: now,
        updatedAt: now,
      );

      // Update local store (sets updatedAt)
      await userRepo.upsert(
        profile.copyWith(
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
          updatedAt: now,
        ),
      );

      // Upsert in Firestore
      await firestore.upsertUserProfile(
        profile.copyWith(updatedAt: now),
      );
    } catch (e) {
      // Don't swallow errors - let them surface for debugging
      rethrow;
    }
  }
}

