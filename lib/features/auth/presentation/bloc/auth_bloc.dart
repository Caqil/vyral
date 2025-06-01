// Fixed AuthBloc - lib/features/auth/presentation/bloc/auth_bloc.dart

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

    // Automatically check auth status when bloc is created
    _checkInitialAuthState();
  }

  // Check auth state immediately when bloc is created
  void _checkInitialAuthState() {
    add(const AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (emit.isDone) return;

    print('🔍 Auth Check: Starting authentication check...');
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // Check if we have stored credentials
      final isAuthenticated = await authRepository.isAuthenticated();
      print('🔍 Auth Check: Has stored credentials: $isAuthenticated');

      if (!isAuthenticated) {
        print('❌ Auth Check: No stored credentials found');
        if (!emit.isDone) {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
        return;
      }

      // Check if we have access token
      final accessToken = await authRepository.getAccessToken();
      final refreshToken = await authRepository.getRefreshToken();
      print('🔍 Auth Check: Access token exists: ${accessToken != null}');
      print('🔍 Auth Check: Refresh token exists: ${refreshToken != null}');

      // Get stored user data
      final userResult = await authRepository.getCurrentUser();

      await userResult.fold(
        (failure) async {
          print('❌ Auth Check: Failed to get user data: ${failure.message}');
          await _attemptTokenRefresh(emit);
        },
        (user) async {
          if (user != null) {
            print('✅ Auth Check: User data found: ${user.username}');
            await _validateAndSetAuthState(user, emit);
          } else {
            print('❌ Auth Check: No user data found');
            if (!emit.isDone) {
              emit(state.copyWith(status: AuthStatus.unauthenticated));
            }
          }
        },
      );
    } catch (e) {
      print('💥 Auth Check: Exception occurred: $e');
      if (!emit.isDone) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Failed to check authentication status: $e',
        ));
      }
    }
  }

  Future<void> _validateAndSetAuthState(
      dynamic user, Emitter<AuthState> emit) async {
    if (emit.isDone) return; // Safety check

    try {
      print(
          '🔍 Token Validation: Starting validation for user: ${user?.id ?? 'null'}');

      // Try to refresh token to validate current session
      final refreshToken = await authRepository.getRefreshToken();
      print(
          '🔑 Token Validation: Got refresh token: ${refreshToken != null ? 'yes' : 'no'}');

      if (refreshToken != null) {
        print('🔄 Token Validation: Attempting token refresh...');
        final refreshResult = await refreshTokenUseCase(refreshToken);

        if (emit.isDone) return; // Check before emitting

        refreshResult.fold(
          (failure) {
            print(
                '❌ Token Validation: Token refresh failed: ${failure.message}');
            // Token refresh failed, logout user
            if (!emit.isDone) {
              emit(state.copyWith(status: AuthStatus.unauthenticated));
            }
            // Clear auth data without awaiting to avoid blocking
            print(
                '🧹 Token Validation: Clearing auth data due to refresh failure');
            authRepository.clearAuthData();
          },
          (authEntity) {
            print('✅ Token Validation: Token refresh successful');
            print(
                '👤 Token Validation: User data - ID: ${authEntity.user.id}, Username: ${authEntity.user.username}');
            // Token refresh successful, user is authenticated
            if (!emit.isDone) {
              emit(state.copyWith(
                status: AuthStatus.authenticated,
                user: authEntity.user,
              ));
            }
          },
        );
      } else {
        print('❌ Token Validation: No refresh token found');
        // No refresh token, user needs to login again
        if (!emit.isDone) {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
        authRepository.clearAuthData();
      }
    } catch (e) {
      print('💥 Token Validation: Exception during validation: $e');
      // If refresh fails, assume user needs to login again
      if (!emit.isDone) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
      authRepository.clearAuthData();
    }
  }

  Future<void> _attemptTokenRefresh(Emitter<AuthState> emit) async {
    if (emit.isDone) return;

    print('🔄 Token Refresh: Attempting emergency token refresh...');

    final refreshToken = await authRepository.getRefreshToken();

    if (refreshToken != null) {
      print('🔄 Token Refresh: Found refresh token, attempting refresh...');
      final result = await refreshTokenUseCase(refreshToken);

      if (emit.isDone) return;

      result.fold(
        (failure) {
          print(
              '❌ Token Refresh: Emergency refresh failed: ${failure.message}');
          if (!emit.isDone) {
            emit(state.copyWith(status: AuthStatus.unauthenticated));
          }
        },
        (authEntity) {
          print('✅ Token Refresh: Emergency refresh successful');
          if (!emit.isDone) {
            emit(state.copyWith(
              status: AuthStatus.authenticated,
              user: authEntity.user,
            ));
          }
        },
      );
    } else {
      print('❌ Token Refresh: No refresh token for emergency refresh');
      if (!emit.isDone) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
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
        // Successfully logged in, set authenticated state
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

    if (emit.isDone) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (_) {
        // Clear all local data and set unauthenticated state
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

  Future<void> _onAuthTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final refreshToken = await authRepository.getRefreshToken();

    if (refreshToken == null) {
      if (!emit.isDone) {
        emit(state.copyWith(
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
