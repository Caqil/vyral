// lib/features/feed/domain/repositories/feed_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/feed_entity.dart';
import '../entities/post_entity.dart';

enum FeedType { personal, following, trending, discover }

abstract class FeedRepository {
  /// Get user feed with pagination
  Future<Either<Failure, FeedEntity>> getFeed({
    required FeedType type,
    int limit = 20,
    int skip = 0,
    bool refresh = false,
  });

  /// Record feed interaction (for analytics and recommendations)
  Future<Either<Failure, void>> recordInteraction({
    required String postId,
    required String interactionType,
    required String source,
    int? timeSpent,
  });

  /// Refresh feed cache
  Future<Either<Failure, void>> refreshFeed({
    required FeedType feedType,
  });

  /// Like a post
  Future<Either<Failure, PostEntity>> likePost({
    required String postId,
    required String reactionType,
  });

  /// Unlike a post
  Future<Either<Failure, PostEntity>> unlikePost({
    required String postId,
  });

  /// Bookmark a post
  Future<Either<Failure, PostEntity>> bookmarkPost({
    required String postId,
  });

  /// Remove bookmark from a post
  Future<Either<Failure, PostEntity>> removeBookmark({
    required String postId,
  });

  /// Share a post
  Future<Either<Failure, PostEntity>> sharePost({
    required String postId,
    String? comment,
  });

  /// Report a post
  Future<Either<Failure, void>> reportPost({
    required String postId,
    required String reason,
    String? description,
  });

  /// Get cached feed if available
  Future<Either<Failure, FeedEntity?>> getCachedFeed({
    required FeedType type,
  });

  /// Cache feed data
  Future<Either<Failure, void>> cacheFeed({
    required FeedType type,
    required FeedEntity feed,
  });
}
