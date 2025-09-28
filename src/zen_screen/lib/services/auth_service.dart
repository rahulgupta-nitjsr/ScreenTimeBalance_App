import 'package:firebase_auth/firebase_auth.dart';

/// A thin wrapper around [FirebaseAuth] that isolates external dependency
/// and provides app-friendly error handling.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Stream of authentication changes exposed for the rest of the app.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Creates a new user account with the provided email and password.
  Future<User?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      return credential.user;
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException.fromFirebase(error);
    }
  }

  /// Signs in an existing user with email and password.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException.fromFirebase(error);
    }
  }

  /// Sends a password reset email to the provided email address.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException.fromFirebase(error);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException.fromFirebase(error);
    }
  }
}

/// Domain-specific exception that hides Firebase-specific error codes
/// while preserving actionable messages for the UI layer.
class AuthServiceException implements Exception {
  AuthServiceException(this.code, this.message);

  final AuthErrorCode code;
  final String message;

  factory AuthServiceException.fromFirebase(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return AuthServiceException(
          AuthErrorCode.invalidEmail,
          'Please enter a valid email address.',
        );
      case 'user-disabled':
        return AuthServiceException(
          AuthErrorCode.userDisabled,
          'This account has been disabled. Contact support for help.',
        );
      case 'user-not-found':
        return AuthServiceException(
          AuthErrorCode.userNotFound,
          'No account found for that email. Please create one first.',
        );
      case 'wrong-password':
        return AuthServiceException(
          AuthErrorCode.wrongPassword,
          'Incorrect password. Please try again.',
        );
      case 'email-already-in-use':
        return AuthServiceException(
          AuthErrorCode.emailAlreadyInUse,
          'That email is already registered. Try signing in instead.',
        );
      case 'weak-password':
        return AuthServiceException(
          AuthErrorCode.weakPassword,
          'Choose a stronger password with at least 8 characters, a number, and a letter.',
        );
      case 'network-request-failed':
        return AuthServiceException(
          AuthErrorCode.networkError,
          'Network error. Check your connection and try again.',
        );
      case 'too-many-requests':
        return AuthServiceException(
          AuthErrorCode.tooManyRequests,
          'Too many attempts. Please wait a moment and try again.',
        );
      default:
        return AuthServiceException(
          AuthErrorCode.unknown,
          'Something went wrong. Please try again later.',
        );
    }
  }

  @override
  String toString() => 'AuthServiceException($code, $message)';
}

/// Authentication-related error codes understood by the rest of the app.
enum AuthErrorCode {
  invalidEmail,
  wrongPassword,
  userNotFound,
  userDisabled,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  tooManyRequests,
  unknown,
}

