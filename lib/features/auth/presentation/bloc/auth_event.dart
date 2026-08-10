part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  final String deviceName;

  const AuthSignInRequested({
    required this.email,
    required this.password,
    this.deviceName = ApiConstants.defaultDeviceName,
  });

  @override
  List<Object?> get props => [email, password, deviceName];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
