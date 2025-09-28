import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zen_screen/models/app_user.dart';
import 'package:zen_screen/providers/auth_provider.dart';
import 'package:zen_screen/services/auth_service.dart';

import 'feature9_authentication_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  group('AuthService', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late AuthService authService;
    late StreamController<User?> authStateController;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authStateController = StreamController<User?>.broadcast();
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => authStateController.stream);
      authService = AuthService(firebaseAuth: mockFirebaseAuth);
    });

    tearDown(() async {
      await authStateController.close();
    });

    test('signInWithEmail delegates to FirebaseAuth', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);

      final user = await authService.signInWithEmail(
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(user, equals(mockUser));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'Password123',
      )).called(1);
    });

    test('registerWithEmail sends verification email', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);
      when(mockUser.sendEmailVerification()).thenAnswer((_) async {});

      final user = await authService.registerWithEmail(
        email: 'test@example.com',
        password: 'Password123',
      );

      expect(user, equals(mockUser));
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'Password123',
      )).called(1);
      verify(mockUser.sendEmailVerification()).called(1);
    });

    test('signOut delegates to FirebaseAuth', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('authStateChanges exposes Firebase stream', () async {
      final mockUser = MockUser();

      expectLater(authService.authStateChanges(), emitsInOrder([mockUser]));

      authStateController.add(mockUser);
    });
  });

  group('AuthController', () {
    late ProviderContainer container;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockCredential = MockUserCredential();

      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream<User?>.empty());

      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(
            AuthService(firebaseAuth: mockFirebaseAuth),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is AuthState.initial', () {
      final state = container.read(authControllerProvider);
      expect(state, const AuthState.initial());
    });

    test('register success transitions to authenticated', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn(null);
      when(mockUser.photoURL).thenReturn(null);
      when(mockUser.emailVerified).thenReturn(false);

      await container.read(authControllerProvider.notifier).register(
            email: 'test@example.com',
            password: 'Password123',
          );

      final state = container.read(authControllerProvider);
      expect(state, isA<Authenticated>());
      expect((state as Authenticated).user.email, 'test@example.com');
    });

    test('signIn failure surfaces AuthError', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(
        FirebaseAuthException(code: 'wrong-password'),
      );

      await container.read(authControllerProvider.notifier).signIn(
            email: 'test@example.com',
            password: 'wrong',
          );

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthError>());
      expect((state as AuthError).exception.code, AuthErrorCode.wrongPassword);
    });

    test('signOut transitions to unauthenticated', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await container.read(authControllerProvider.notifier).signOut();

      final state = container.read(authControllerProvider);
      expect(state, const AuthState.unauthenticated());
    });
  });

  group('AppUser model', () {
    test('fromFirebase maps Firebase user', () {
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('abc');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn('https://example.com/photo.png');
      when(mockUser.emailVerified).thenReturn(true);

      final appUser = AppUser.fromFirebase(mockUser);

      expect(appUser.id, 'abc');
      expect(appUser.email, 'test@example.com');
      expect(appUser.displayName, 'Test User');
      expect(appUser.photoUrl, 'https://example.com/photo.png');
      expect(appUser.emailVerified, isTrue);
    });

    test('copyWith updates fields', () {
      const appUser = AppUser(id: '1', email: 'test@example.com');

      final updated = appUser.copyWith(
        displayName: 'Updated',
        emailVerified: true,
      );

      expect(updated.displayName, 'Updated');
      expect(updated.emailVerified, isTrue);
      expect(updated.id, appUser.id);
    });
  });
}

