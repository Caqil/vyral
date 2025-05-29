// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String emailOrUsername;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.emailOrUsername,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [emailOrUsername, password, rememberMe];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? displayName;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;

  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.displayName,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.phone,
  });

  @override
  List<Object?> get props => [
        username,
        email,
        password,
        firstName,
        lastName,
        displayName,
        bio,
        dateOfBirth,
        gender,
        phone,
      ];
}

class AuthLogoutRequested extends AuthEvent {
  final bool logoutFromAllSessions;

  const AuthLogoutRequested({this.logoutFromAllSessions = false});

  @override
  List<Object?> get props => [logoutFromAllSessions];
}

class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested();
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const AuthResetPasswordRequested({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];
}

class AuthVerifyEmailRequested extends AuthEvent {
  final String token;

  const AuthVerifyEmailRequested({required this.token});

  @override
  List<Object?> get props => [token];
}

class AuthCheckUserExistsRequested extends AuthEvent {
  final String? username;
  final String? email;

  const AuthCheckUserExistsRequested({
    this.username,
    this.email,
  });

  @override
  List<Object?> get props => [username, email];
}

class AuthSessionsRequested extends AuthEvent {
  const AuthSessionsRequested();
}

class AuthRevokeSessionRequested extends AuthEvent {
  final String sessionId;

  const AuthRevokeSessionRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class AuthClearErrorRequested extends AuthEvent {
  const AuthClearErrorRequested();
}
