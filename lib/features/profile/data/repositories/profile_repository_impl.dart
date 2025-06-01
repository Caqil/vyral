// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:vyral/features/profile/data/models/user_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/entities/follow_status_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/media_entity.dart';
import '../../domain/entities/story_highlight_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final String? Function() getCurrentUserId; // Function to get current user ID

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.getCurrentUserId,
  });

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      final currentUserId = getCurrentUserId();
      UserModel user;

      // Check if requesting own profile or another user's profile
      if (currentUserId != null && currentUserId == userId) {
        // Get current user's profile using auth endpoint
        user = await remoteDataSource.getCurrentUserProfile();
      } else {
        // Get other user's profile using public endpoint
        user = await remoteDataSource.getUserProfile(userId);
      }

      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      final errorMessage = e.toString();

      // Handle specific privacy/access errors
      if (errorMessage.contains('This profile is private')) {
        return Left(PrivacyFailure(message: 'This profile is private'));
      } else if (errorMessage.contains('This account has been suspended')) {
        return Left(SuspendedAccountFailure(
            message: 'This account has been suspended'));
      } else if (errorMessage.contains('User not found')) {
        return Left(NotFoundFailure(message: 'User not found'));
      } else if (errorMessage.contains('Authentication required')) {
        return Left(AuthenticationFailure(message: 'Authentication required'));
      }

      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserByUsername(String username) async {
    try {
      final user = await remoteDataSource.getUserByUsername(username);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('This profile is private')) {
        return Left(PrivacyFailure(message: 'This profile is private'));
      } else if (errorMessage.contains('This account has been suspended')) {
        return Left(SuspendedAccountFailure(
            message: 'This account has been suspended'));
      } else if (errorMessage.contains('User not found')) {
        return Left(NotFoundFailure(message: 'User not found'));
      }

      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, UserStatsEntity>> getUserStats(String userId) async {
    try {
      final stats = await remoteDataSource.getUserStats(userId);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('Cannot view stats for private profile')) {
        return Left(
            PrivacyFailure(message: 'Cannot view stats for private profile'));
      }

      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, FollowStatusEntity>> getFollowStatus(
      String userId) async {
    try {
      final currentUserId = getCurrentUserId();

      // Don't get follow status for own profile
      if (currentUserId != null && currentUserId == userId) {
        return Left(ValidationFailure(
            message: 'Cannot get follow status for own profile'));
      }

      final status = await remoteDataSource.getFollowStatus(userId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, FollowStatusEntity>> followUser(String userId) async {
    try {
      final currentUserId = getCurrentUserId();

      // Cannot follow yourself
      if (currentUserId != null && currentUserId == userId) {
        return Left(ValidationFailure(message: 'Cannot follow yourself'));
      }

      final status = await remoteDataSource.followUser(userId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, FollowStatusEntity>> unfollowUser(
      String userId) async {
    try {
      final currentUserId = getCurrentUserId();

      // Cannot unfollow yourself
      if (currentUserId != null && currentUserId == userId) {
        return Left(ValidationFailure(message: 'Cannot unfollow yourself'));
      }

      final status = await remoteDataSource.unfollowUser(userId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts(
    String userId,
    int page,
    int limit,
  ) async {
    try {
      final posts = await remoteDataSource.getUserPosts(userId, page, limit);
      return Right(posts.cast<PostEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('Cannot view posts from private profile')) {
        return Left(
            PrivacyFailure(message: 'Cannot view posts from private profile'));
      }

      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MediaEntity>>> getUserMedia(
    String userId,
    int page,
    int limit, {
    String? type,
  }) async {
    try {
      final media =
          await remoteDataSource.getUserMedia(userId, page, limit, type);
      return Right(media.cast<MediaEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('Cannot view media from private profile')) {
        return Left(
            PrivacyFailure(message: 'Cannot view media from private profile'));
      }

      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StoryHighlightEntity>>> getUserHighlights(
      String userId) async {
    try {
      final highlights = await remoteDataSource.getUserHighlights(userId);
      return Right(highlights.cast<StoryHighlightEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      // For highlights, we return empty list on privacy errors
      return Right([]);
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getFollowers(
    String userId,
    int page,
    int limit,
  ) async {
    try {
      final followers =
          await remoteDataSource.getFollowers(userId, page, limit);
      return Right(followers.cast<UserEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('Cannot view followers of private profile')) {
        return Left(PrivacyFailure(
            message: 'Cannot view followers of private profile'));
      }

      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getFollowing(
    String userId,
    int page,
    int limit,
  ) async {
    try {
      final following =
          await remoteDataSource.getFollowing(userId, page, limit);
      return Right(following.cast<UserEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('Cannot view following of private profile')) {
        return Left(PrivacyFailure(
            message: 'Cannot view following of private profile'));
      }

      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final user = await remoteDataSource.updateProfile(data);
      return Right(user);
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
}

// Add new failure types for privacy and suspended accounts
class PrivacyFailure extends Failure {
  const PrivacyFailure({required String message}) : super(message: message);
}

class SuspendedAccountFailure extends Failure {
  const SuspendedAccountFailure({required String message})
      : super(message: message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message: message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required String message})
      : super(message: message);
}
