import 'package:dartz/dartz.dart';
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

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      final user = await remoteDataSource.getUserProfile(userId);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
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
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, FollowStatusEntity>> getFollowStatus(
      String userId) async {
    try {
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
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
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
      return Right(media);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StoryHighlightEntity>>> getUserHighlights(
      String userId) async {
    try {
      final highlights = await remoteDataSource.getUserHighlights(userId);
      return Right(highlights);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
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
      return Right(followers);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
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
      return Right(following);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
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
