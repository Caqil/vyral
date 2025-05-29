// lib/features/feed/data/repositories/feed_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/feed_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';
import '../datasources/feed_local_datasource.dart';
import '../models/feed_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;
  final FeedLocalDataSource localDataSource;

  FeedRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, FeedEntity>> getFeed({
    required FeedType type,
    int limit = 20,
    int skip = 0,
    bool refresh = false,
  }) async {
    try {
      // If refreshing or no skip (first page), get from remote
      if (refresh || skip == 0) {
        try {
          final remoteFeed = await remoteDataSource.getFeed(
            type: type,
            limit: limit,
            skip: skip,
            refresh: refresh,
          );

          // Cache the feed if it's the first page
          if (skip == 0) {
            await localDataSource.cacheFeed(type: type, feed: remoteFeed);
          }

          return Right(remoteFeed);
        } on NetworkException catch (e) {
          // If network fails and we're on first page, try cache
          if (skip == 0) {
            final cachedFeed = await localDataSource.getCachedFeed(type: type);
            if (cachedFeed != null) {
              return Right(cachedFeed);
            }
          }
          return Left(NetworkFailure(message: e.message));
        }
      } else {
        // For pagination (skip > 0), always get from remote
        final remoteFeed = await remoteDataSource.getFeed(
          type: type,
          limit: limit,
          skip: skip,
          refresh: refresh,
        );
        return Right(remoteFeed);
      }
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
  Future<Either<Failure, void>> recordInteraction({
    required String postId,
    required String interactionType,
    required String source,
    int? timeSpent,
  }) async {
    try {
      await remoteDataSource.recordInteraction(
        postId: postId,
        interactionType: interactionType,
        source: source,
        timeSpent: timeSpent,
      );
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
  Future<Either<Failure, void>> refreshFeed({
    required FeedType feedType,
  }) async {
    try {
      await remoteDataSource.refreshFeed(feedType: feedType);
      // Clear the cache for this feed type to force refresh
      await localDataSource.clearFeedCache(type: feedType);
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
  Future<Either<Failure, PostEntity>> likePost({
    required String postId,
    required String reactionType,
  }) async {
    try {
      final updatedPost = await remoteDataSource.likePost(
        postId: postId,
        reactionType: reactionType,
      );

      // Update the post in cached feeds
      await localDataSource.updatePostInCachedFeeds(
        postId: postId,
        updates: {
          'is_liked': true,
          'stats': updatedPost.postStats.toJson(),
        },
      );

      return Right(updatedPost);
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
  Future<Either<Failure, PostEntity>> unlikePost({
    required String postId,
  }) async {
    try {
      final updatedPost = await remoteDataSource.unlikePost(postId: postId);

      // Update the post in cached feeds
      await localDataSource.updatePostInCachedFeeds(
        postId: postId,
        updates: {
          'is_liked': false,
          'stats': updatedPost.postStats.toJson(),
        },
      );

      return Right(updatedPost);
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
  Future<Either<Failure, PostEntity>> bookmarkPost({
    required String postId,
  }) async {
    try {
      final updatedPost = await remoteDataSource.bookmarkPost(postId: postId);

      // Update the post in cached feeds
      await localDataSource.updatePostInCachedFeeds(
        postId: postId,
        updates: {
          'is_bookmarked': true,
          'stats': updatedPost.postStats.toJson(),
        },
      );

      return Right(updatedPost);
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
  Future<Either<Failure, PostEntity>> removeBookmark({
    required String postId,
  }) async {
    try {
      final updatedPost = await remoteDataSource.removeBookmark(postId: postId);

      // Update the post in cached feeds
      await localDataSource.updatePostInCachedFeeds(
        postId: postId,
        updates: {
          'is_bookmarked': false,
          'stats': updatedPost.postStats.toJson(),
        },
      );

      return Right(updatedPost);
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
  Future<Either<Failure, PostEntity>> sharePost({
    required String postId,
    String? comment,
  }) async {
    try {
      final updatedPost = await remoteDataSource.sharePost(
        postId: postId,
        comment: comment,
      );

      // Update the post in cached feeds
      await localDataSource.updatePostInCachedFeeds(
        postId: postId,
        updates: {
          'stats': updatedPost.postStats.toJson(),
        },
      );

      return Right(updatedPost);
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
  Future<Either<Failure, void>> reportPost({
    required String postId,
    required String reason,
    String? description,
  }) async {
    try {
      await remoteDataSource.reportPost(
        postId: postId,
        reason: reason,
        description: description,
      );
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
  Future<Either<Failure, FeedEntity?>> getCachedFeed({
    required FeedType type,
  }) async {
    try {
      final cachedFeed = await localDataSource.getCachedFeed(type: type);
      return Right(cachedFeed);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get cached feed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheFeed({
    required FeedType type,
    required FeedEntity feed,
  }) async {
    try {
      final feedModel = feed is FeedModel ? feed : FeedModel.fromEntity(feed);
      await localDataSource.cacheFeed(type: type, feed: feedModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to cache feed: $e'));
    }
  }
}
