import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:ratrix/features/auth/data/repositories/auth_repository.dart';
import 'package:ratrix/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late StreamController<AuthUser?> authStateController;

  setUp(() {
    repository = MockAuthRepository();
    authStateController = StreamController<AuthUser?>.broadcast();
    when(() => repository.onAuthStateChange)
        .thenAnswer((_) => authStateController.stream);
    when(() => repository.restoreSession()).thenAnswer((_) async => null);
  });

  tearDown(() => authStateController.close());

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when signIn succeeds',
      build: () => AuthBloc(repository),
      setUp: () {
        when(
          () => repository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          ),
        ).thenAnswer((_) async {
          authStateController.add(const AuthUser(id: '1', email: 'a@b.com'));
        });
      },
      act: (bloc) async {
        bloc.add(const AuthSubscriptionRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AuthSignInRequested(email: 'a@b.com', password: 'pw'));
      },
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
        const AuthState(status: AuthStatus.unauthenticated, isSubmitting: true),
        const AuthState(
          status: AuthStatus.authenticated,
          userEmail: 'a@b.com',
          isSubmitting: false,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error message when signIn throws AuthException',
      build: () => AuthBloc(repository),
      setUp: () {
        when(
          () => repository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          ),
        ).thenThrow(const AuthException('Invalid credentials.'));
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(email: 'a@b.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthState(isSubmitting: true),
        const AuthState(
          isSubmitting: false,
          error: 'Sign in failed. Please check your credentials and try again.',
        ),
      ],
    );
  });
}
