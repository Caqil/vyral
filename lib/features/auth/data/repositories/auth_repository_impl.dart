// Updated lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String emailOrUsername,
    required String password,
    String? deviceInfo,
  }) async {
    try {
      final deviceInfoString = deviceInfo ?? await _getDeviceInfo();

      final request = LoginRequestModel(
        emailOrUsername: emailOrUsername,
        password: password,
        deviceInfo: deviceInfoString,
      );

      final authResponse = await remoteDataSource.login(request);

      // Convert UserEntity to UserModel for storage
      final userModel = authResponse.user is UserModel
          ? authResponse.user as UserModel
          : UserModel.fromEntity(authResponse.user);

      // Save auth data locally
      await localDataSource.saveAuthData(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        user: userModel,
      );

      return Right(authResponse);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, type: e.type));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final request = RegisterRequestModel(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        bio: bio,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
      );

      final authResponse = await remoteDataSource.register(request);

      // Convert UserEntity to UserModel for storage
      final userModel = authResponse.user is UserModel
          ? authResponse.user
          : UserModel.fromEntity(authResponse.user);

      // Save auth data locally
      await localDataSource.saveAuthData(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        user: userModel,
      );

      return Right(authResponse);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, type: e.type));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequestModel(refreshToken: refreshToken);

      // Get existing user data before refresh
      final existingUser = await localDataSource.getCurrentUser();

      final authResponse = await remoteDataSource.refreshToken(request);

      // If the refresh response doesn't have valid user data (empty or minimal),
      // use the existing user data
      UserModel userToSave;
      if (existingUser != null &&
          (authResponse.user.id.isEmpty ||
              authResponse.user.username.isEmpty)) {
        // Use existing user data with new tokens
        userToSave = existingUser;

        // Create a new auth response with the existing user data
        final updatedAuthResponse = authResponse.copyWithUser(existingUser);

        // Save auth data locally
        await localDataSource.saveAuthData(
          accessToken: updatedAuthResponse.accessToken,
          refreshToken: updatedAuthResponse.refreshToken,
          user: userToSave,
        );

        return Right(updatedAuthResponse);
      } else {
        // The refresh response has valid user data, use it
        userToSave = authResponse.user is UserModel
            ? authResponse.user as UserModel
            : UserModel.fromEntity(authResponse.user);

        // Save auth data locally
        await localDataSource.saveAuthData(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          user: userToSave,
        );

        return Right(authResponse);
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, type: e.type));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      print('RefreshToken Error: $e'); // Debug log
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return const Right(null);
    } on AuthException catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(AuthFailure(message: e.message, type: e.type));
    } on ServerException catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logoutFromAllSessions() async {
    try {
      await remoteDataSource.logoutFromAllSessions();
      await localDataSource.clearAuthData();
      return const Right(null);
    } on AuthException catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(AuthFailure(message: e.message, type: e.type));
    } on ServerException catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequestModel(email: email);
      await remoteDataSource.forgotPassword(request);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final request = ResetPasswordRequestModel(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      await remoteDataSource.resetPassword(request);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    try {
      final request = VerifyEmailRequestModel(token: token);
      await remoteDataSource.verifyEmail(request);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getUserSessions() async {
    try {
      final sessions = await remoteDataSource.getUserSessions();
      return Right(sessions);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, type: e.type));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> revokeSession(String sessionId) async {
    try {
      await remoteDataSource.revokeSession(sessionId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, type: e.type));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUserExists({
    String? username,
    String? email,
  }) async {
    try {
      final exists = await remoteDataSource.checkUserExists(
        username: username,
        email: email,
      );
      return Right(exists);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCurrentUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await localDataSource.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await localDataSource.getAccessToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await localDataSource.getRefreshToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    await localDataSource.clearAuthData();
  }

  // New methods for refresh time tracking
  @override
  Future<void> storeLastRefreshTime() async {
    await localDataSource.storeLastRefreshTime();
  }

  @override
  Future<DateTime?> getLastRefreshTime() async {
    return await localDataSource.getLastRefreshTime();
  }

  @override
  Future<void> clearLastRefreshTime() async {
    await localDataSource.clearLastRefreshTime();
  }

  /// Get device information for login tracking
  Future<String> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}, Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} ${iosInfo.model}, iOS ${iosInfo.systemVersion}';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }
}
