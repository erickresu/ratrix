import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/api_config.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await repository.restoreSession();
    emit(
      state.copyWith(
        status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        userEmail: user?.email,
        isSubmitting: false,
        clearError: true,
      ),
    );
    await emit.forEach<AuthUser?>(
      repository.onAuthStateChange,
      onData: (user) => state.copyWith(
        status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        userEmail: user?.email,
        isSubmitting: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await repository.signIn(
        email: event.email,
        password: event.password,
        deviceName: event.deviceName,
      );
    } on AuthException catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
