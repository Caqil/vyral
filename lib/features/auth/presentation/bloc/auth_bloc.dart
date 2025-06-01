// Simplified AuthBloc with removed aggressive refresh logic
// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/core/utils/logger.dart';
import 'package:vyral/main.dart';
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

    // Automatically check auth status when bloc is created
    _checkInitialAuthState();
  }

  // Check auth state immediately when bloc is created
  void _checkInitialAuthState() {
    add(const AuthCheckRequested());
  }

  /// Simplified auth check - no aggressive refresh logic
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (emit.isDone) return;

    AppLogger.debug('🔍 Auth Check: Starting authentication check...');
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // Check if we have stored credentials
      final isAuthenticated = await authRepository.isAuthenticated();
      AppLogger.debug(
          '🔍 Auth Check: Has stored credentials: $isAuthenticated');

      if (!isAuthenticated) {
        AppLogger.debug('❌ Auth Check: No stored credentials found');
        if (!emit.isDone) {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
        return;
      }

      // Get stored user data
      final userResult = await authRepository.getCurrentUser();

      await userResult.fold(
        (failure) async {
          AppLogger.debug(
              '❌ Auth Check: Failed to get user data: ${failure.message}');
          // Clear invalid data and set unauthenticated
          await authRepository.clearAuthData();
          if (!emit.isDone) {
            emit(state.copyWith(status: AuthStatus.unauthenticated));
          }
        },
        (user) async {
          if (user != null) {
            AppLogger.debug('✅ Auth Check: User data found: ${user.username}');
            // Set authenticated state with existing user data
            if (!emit.isDone) {
              emit(state.copyWith(
                status: AuthStatus.authenticated,
                user: user,
              ));
              SocialNetworkApp.setCurrentUserId(user.id);
            }
          } else {
            AppLogger.debug('❌ Auth Check: No user data found');
            await authRepository.clearAuthData();
            if (!emit.isDone) {
              emit(state.copyWith(status: AuthStatus.unauthenticated));
            }
          }
        },
      );
    } catch (e) {
      AppLogger.debug('💥 Auth Check: Exception occurred: $e');
      if (!emit.isDone) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Failed to check authentication status: $e',
        ));
      }
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

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
        validationErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (authEntity) {
        SocialNetworkApp.setCurrentUserId(authEntity.user.id);
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          user: authEntity.user,
          successMessage: 'Login successful',
        ));
      },
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

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
        validationErrors: failure is ValidationFailure ? failure.errors : null,
      )),
      (authEntity) {
        SocialNetworkApp.setCurrentUserId(authEntity.user.id);
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          user: authEntity.user,
          successMessage: 'Registration successful',
        ));
      },
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

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        // Clear all local data and set unauthenticated state
        SocialNetworkApp.clearCurrentUserId();
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
          user: null,
          sessions: null,
          successMessage: 'Logout successful',
        ));
      },
    );
  }

  /// Manual token refresh only - no automatic refresh
  Future<void> _onAuthTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.debug('🔄 Manual Token Refresh: User requested token refresh');

    emit(state.copyWith(isLoading: true));

    final refreshToken = await authRepository.getRefreshToken();

    if (refreshToken == null) {
      if (!emit.isDone) {
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: 'No refresh token available',
        ));
      }
      return;
    }

    final result = await refreshTokenUseCase(refreshToken);

    if (emit.isDone) return;

    result.fold(
      (failure) {
        // Clear auth data on refresh failure
        authRepository.clearAuthData();
        SocialNetworkApp.clearCurrentUserId();
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: failure.message,
        ));
      },
      (authEntity) {
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          user: authEntity.user,
          successMessage: 'Token refreshed successfully',
        ));
        SocialNetworkApp.setCurrentUserId(authEntity.user.id);
      },
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

    if (emit.isDone) return;

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

    if (emit.isDone) return;

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

    if (emit.isDone) return;

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

    if (emit.isDone) return;

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

    if (emit.isDone) return;

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

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedSessions = state.sessions
            ?.where((session) => session.id != event.sessionId)
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
