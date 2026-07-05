import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginSubmitted extends AuthEvent {
  final String ssnOrEmail;
  final String password;
  final bool rememberMe;

  const LoginSubmitted({
    required this.ssnOrEmail,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [ssnOrEmail, password, rememberMe];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class TokenExpired extends AuthEvent {
  const TokenExpired();
}
