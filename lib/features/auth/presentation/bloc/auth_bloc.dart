// Final AuthBloc with proper storage constants usage
// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/main.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/storage_constants.dart';
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

  // Track last refresh attempt to prevent rapid successive calls
  DateTime? _lastRefreshAttempt;
  static const Duration _minRefreshInterval =
      Duration(days: 1); // Only refresh every 1-3 days
  static const Duration _maxRefreshInterval =
      Duration(days: 3); // Force refresh after 3 days

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

  /// Check if token refresh is needed based on last refresh time
  Future<bool> _shouldRefreshToken() async {
    try {
      // Access secure storage through repository
      final secureStorage =
          (authRepository as dynamic).localDataSource._secureStorage;
      final lastRefreshString =
          await secureStorage.read(StorageConstants.lastTokenRefresh);

      if (lastRefreshString == null) {
        print('🕐 Token Check: No last refresh time found, refresh needed');
        return true; // First time, should refresh
      }

      final lastRefreshTime = DateTime.parse(lastRefreshString);
      final timeSinceRefresh = DateTime.now().difference(lastRefreshTime);

      print(
          '🕐 Token Check: Last refresh was ${timeSinceRefresh.inDays} days ago');

      // Refresh if it's been more than 1 day since last refresh
      return timeSinceRefresh >= _minRefreshInterval;
    } catch (e) {
      print('❌ Token Check: Error checking refresh time: $e');
      return true; // If we can't check, better to refresh
    }
  }

  /// Store the last refresh time
  Future<void> _storeLastRefreshTime() async {
    try {
      final secureStorage =
          (authRepository as dynamic).localDataSource._secureStorage;
      await secureStorage.write(
          StorageConstants.lastTokenRefresh, DateTime.now().toIso8601String());
      print('✅ Token Refresh: Stored last refresh time');
    } catch (e) {
      print('❌ Token Refresh: Failed to store refresh time: $e');
    }
  }

  /// Clear the last refresh time
  Future<void> _clearLastRefreshTime() async {
    try {
      final secureStorage =
          (authRepository as dynamic).localDataSource._secureStorage;
      await secureStorage.delete(StorageConstants.lastTokenRefresh);
      print('🧹 Cleared last refresh time');
    } catch (e) {
      print('❌ Failed to clear refresh time: $e');
    }
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

      // Get stored user data first
      final userResult = await authRepository.getCurrentUser();

      await userResult.fold(
        (failure) async {
          print('❌ Auth Check: Failed to get user data: ${failure.message}');
          // Only attempt refresh if we have tokens but no user data
          await _attemptTokenRefreshIfNeeded(emit, forceRefresh: false);
        },
        (user) async {
          if (user != null) {
            print('✅ Auth Check: User data found: ${user.username}');

            // Check if we need to refresh based on time
            final shouldRefresh = await _shouldRefreshToken();

            if (shouldRefresh) {
              print('🔄 Auth Check: Token refresh needed (1-3 days passed)');
              await _attemptTokenRefreshIfNeeded(emit, forceRefresh: false);
            } else {
              print(
                  '✅ Auth Check: Using cached auth data (refresh not needed)');
              // Set authenticated state with existing user data
              if (!emit.isDone) {
                emit(state.copyWith(
                  status: AuthStatus.authenticated,
                  user: user,
                ));
                SocialNetworkApp.setCurrentUserId(user.id);
              }
            }
          } else {
            print('❌ Auth Check: No user data found');
            await _attemptTokenRefreshIfNeeded(emit, forceRefresh: false);
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

  /// Only attempt token refresh if we haven't done it recently or if forced
  /// This prevents rapid successive refresh attempts that cause 429 errors
  Future<void> _attemptTokenRefreshIfNeeded(
    Emitter<AuthState> emit, {
    bool forceRefresh = false,
  }) async {
    if (emit.isDone) return;

    final now = DateTime.now();

    // Check if we've attempted refresh recently (prevent rapid retries)
    if (!forceRefresh && _lastRefreshAttempt != null) {
      final timeSinceLastAttempt = now.difference(_lastRefreshAttempt!);
      if (timeSinceLastAttempt < Duration(minutes: 5)) {
        print(
            '⏰ Token Refresh: Skipping refresh - attempted ${timeSinceLastAttempt.inMinutes} minutes ago');
        if (!emit.isDone) {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
        return;
      }
    }

    print('🔄 Token Refresh: Attempting token refresh...');
    _lastRefreshAttempt = now;

    final refreshToken = await authRepository.getRefreshToken();

    if (refreshToken != null) {
      print('🔄 Token Refresh: Found refresh token, attempting refresh...');
      final result = await refreshTokenUseCase(refreshToken);

      if (emit.isDone) return;

      result.fold(
        (failure) {
          print('❌ Token Refresh: Failed: ${failure.message}');
          if (!emit.isDone) {
            emit(state.copyWith(status: AuthStatus.unauthenticated));
          }
          // Clear invalid tokens
          authRepository.clearAuthData();
          _clearLastRefreshTime();
        },
        (authEntity) {
          print('✅ Token Refresh: Successful');
          // Store the refresh time
          _storeLastRefreshTime();

          if (!emit.isDone) {
            emit(state.copyWith(
              status: AuthStatus.authenticated,
              user: authEntity.user,
            ));
            SocialNetworkApp.setCurrentUserId(authEntity.user.id);
          }
        },
      );
    } else {
      print('❌ Token Refresh: No refresh token available');
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
        // Reset refresh tracking on successful login and store refresh time
        _lastRefreshAttempt = null;
        _storeLastRefreshTime(); // Store the login time as refresh time
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
        // Reset refresh tracking on successful registration and store refresh time
        _lastRefreshAttempt = null;
        _storeLastRefreshTime(); // Store the registration time as refresh time
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
        // Clear refresh tracking on logout
        _lastRefreshAttempt = null;
        _clearLastRefreshTime();

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
    // This is an explicit refresh request, so we force it
    print('🔄 Explicit Token Refresh: User requested token refresh');

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
      (authEntity) {
        // Store the refresh time on successful explicit refresh
        _storeLastRefreshTime();

        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: authEntity.user,
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
