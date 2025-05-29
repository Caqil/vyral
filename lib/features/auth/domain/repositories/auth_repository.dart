import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';
import '../entities/session_entity.dart';

abstract class AuthRepository {
  /// Login with email/username and password
  Future<Either<Failure, AuthEntity>> login({
    required String emailOrUsername,
    required String password,
    String? deviceInfo,
  });

  /// Register new user
  Future<Either<Failure, AuthEntity>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? displayName,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
  });

  /// Refresh access token
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken);

  /// Logout from current session
  Future<Either<Failure, void>> logout();

  /// Logout from all sessions
  Future<Either<Failure, void>> logoutFromAllSessions();

  /// Send forgot password email
  Future<Either<Failure, void>> forgotPassword(String email);

  /// Reset password with token
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  /// Verify email with token
  Future<Either<Failure, void>> verifyEmail(String token);

  /// Get user sessions
  Future<Either<Failure, List<SessionEntity>>> getUserSessions();

  /// Revoke specific session
  Future<Either<Failure, void>> revokeSession(String sessionId);

  /// Check if user exists
  Future<Either<Failure, bool>> checkUserExists({
    String? username,
    String? email,
  });

  /// Get current user from local storage
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Get stored refresh token
  Future<String?> getRefreshToken();

  /// Clear all auth data
  Future<void> clearAuthData();
}
