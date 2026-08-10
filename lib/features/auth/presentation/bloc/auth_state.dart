part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userEmail;
  final bool isSubmitting;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userEmail,
    this.isSubmitting = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userEmail,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      userEmail: userEmail ?? this.userEmail,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, userEmail, isSubmitting, error];
}
