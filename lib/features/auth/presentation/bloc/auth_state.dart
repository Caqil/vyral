import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/session_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final Map<String, List<String>>? validationErrors;
  final List<SessionEntity>? sessions;
  final bool isLoading;
  final bool isCheckingUser;
  final bool userExists;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.validationErrors,
    this.sessions,
    this.isLoading = false,
    this.isCheckingUser = false,
    this.userExists = false,
    this.successMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    Map<String, List<String>>? validationErrors,
    List<SessionEntity>? sessions,
    bool? isLoading,
    bool? isCheckingUser,
    bool? userExists,
    String? successMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      validationErrors: validationErrors,
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      isCheckingUser: isCheckingUser ?? this.isCheckingUser,
      userExists: userExists ?? this.userExists,
      successMessage: successMessage,
    );
  }

  AuthState clearError() {
    return copyWith(
      errorMessage: null,
      validationErrors: null,
      successMessage: null,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        validationErrors,
        sessions,
        isLoading,
        isCheckingUser,
        userExists,
        successMessage,
      ];

  // Helper getters
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get hasError => errorMessage != null || validationErrors != null;
  bool get hasValidationErrors =>
      validationErrors != null && validationErrors!.isNotEmpty;
}
