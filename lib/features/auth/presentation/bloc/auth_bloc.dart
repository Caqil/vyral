import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.refreshTokenUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyEmailUseCase,
    required this.authRepository,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthTokenRefreshRequested>(_onAuthTokenRefreshRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthVerifyEmailRequested>(_onAuthVerifyEmailRequested);
    on<AuthCheckUserExistsRequested>(_onAuthCheckUserExistsRequested);
    on<AuthSessionsRequested>(_onAuthSessionsRequested);
    on<AuthRevokeSessionRequested>(_onAuthRevokeSessionRequested);
    on<AuthClearErrorRequested>(_onAuthClearErrorRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final isAuthenticated = await authRepository.isAuthenticated();

    if (isAuthenticated) {
      final userResult = await authRepository.getCurrentUser();

      userResult.fold(
        (failure) => emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        )),
        (user) {
          if (user != null) {
            emit(state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
            ));
          } else {
            emit(state.copyWith(status: AuthStatus.unauthenticated));
          }
        },
      );
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      validationErrors: null,
    ));

    final params = LoginParams(
      emailOrUsername: event.emailOrUsername,
      password: event.password,
    );

    final result = await loginUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
        validationErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (authEntity) => emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: authEntity.user,
        successMessage: 'Login successful',
      )),
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      validationErrors: null,
    ));

    final params = RegisterParams(
      username: event.username,
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      displayName: event.displayName,
      bio: event.bio,
      dateOfBirth: event.dateOfBirth,
      gender: event.gender,
      phone: event.phone,
    );

    final result = await registerUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
        validationErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (authEntity) => emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: authEntity.user,
        successMessage: 'Registration successful',
      )),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = event.logoutFromAllSessions
        ? await authRepository.logoutFromAllSessions()
        : await logoutUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        user: null,
        sessions: null,
        successMessage: 'Logout successful',
      )),
    );
  }

  Future<void> _onAuthTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final refreshToken = await authRepository.getRefreshToken();

    if (refreshToken == null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: 'No refresh token available',
      ));
      return;
    }

    final result = await refreshTokenUseCase(refreshToken);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: failure.message,
      )),
      (authEntity) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: authEntity.user,
      )),
    );
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      validationErrors: null,
    ));

    final result = await forgotPasswordUseCase(event.email);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        validationErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (_) => emit(state.copyWith(
        isLoading: false,
        successMessage: 'Password reset email sent successfully',
      )),
    );
  }

  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      validationErrors: null,
    ));

    final result = await authRepository.resetPassword(
      token: event.token,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        validationErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (_) => emit(state.copyWith(
        isLoading: false,
        successMessage: 'Password reset successful',
      )),
    );
  }

  Future<void> _onAuthVerifyEmailRequested(
    AuthVerifyEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    final result = await verifyEmailUseCase(event.token);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isLoading: false,
        successMessage: 'Email verified successfully',
      )),
    );
  }

  Future<void> _onAuthCheckUserExistsRequested(
    AuthCheckUserExistsRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isCheckingUser: true));

    final result = await authRepository.checkUserExists(
      username: event.username,
      email: event.email,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isCheckingUser: false,
        errorMessage: failure.message,
      )),
      (exists) => emit(state.copyWith(
        isCheckingUser: false,
        userExists: exists,
      )),
    );
  }

  Future<void> _onAuthSessionsRequested(
    AuthSessionsRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await authRepository.getUserSessions();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (sessions) => emit(state.copyWith(
        isLoading: false,
        sessions: sessions,
      )),
    );
  }

  Future<void> _onAuthRevokeSessionRequested(
    AuthRevokeSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await authRepository.revokeSession(event.sessionId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        // Remove the revoked session from the list
        final updatedSessions = state.sessions
            ?.where(
              (session) => session.id != event.sessionId,
            )
            .toList();

        emit(state.copyWith(
          isLoading: false,
          sessions: updatedSessions,
          successMessage: 'Session revoked successfully',
        ));
      },
    );
  }

  Future<void> _onAuthClearErrorRequested(
    AuthClearErrorRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.clearError());
  }
}
