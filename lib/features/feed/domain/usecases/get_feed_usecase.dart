// lib/features/feed/domain/usecases/get_feed_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/feed_entity.dart';
import '../entities/post_entity.dart';
import '../repositories/feed_repository.dart';

class GetFeedUseCase {
  final FeedRepository repository;

  GetFeedUseCase(this.repository);

  Future<Either<Failure, FeedEntity>> call(GetFeedParams params) async {
    return await repository.getFeed(
      type: params.type,
      limit: params.limit,
      skip: params.skip,
      refresh: params.refresh,
    );
  }
}

class GetFeedParams {
  final FeedType type;
  final int limit;
  final int skip;
  final bool refresh;

  GetFeedParams({
    required this.type,
    this.limit = 20,
    this.skip = 0,
    this.refresh = false,
  });
}

// lib/features/feed/domain/usecases/like_post_usecase.dart
class LikePostUseCase {
  final FeedRepository repository;

  LikePostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(LikePostParams params) async {
    return await repository.likePost(
      postId: params.postId,
      reactionType: params.reactionType,
    );
  }
}

class LikePostParams {
  final String postId;
  final String reactionType;

  LikePostParams({
    required this.postId,
    this.reactionType = 'like',
  });
}

// lib/features/feed/domain/usecases/unlike_post_usecase.dart
class UnlikePostUseCase {
  final FeedRepository repository;

  UnlikePostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(String postId) async {
    return await repository.unlikePost(postId: postId);
  }
}

// lib/features/feed/domain/usecases/bookmark_post_usecase.dart
class BookmarkPostUseCase {
  final FeedRepository repository;

  BookmarkPostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(String postId) async {
    return await repository.bookmarkPost(postId: postId);
  }
}

// lib/features/feed/domain/usecases/remove_bookmark_usecase.dart
class RemoveBookmarkUseCase {
  final FeedRepository repository;

  RemoveBookmarkUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(String postId) async {
    return await repository.removeBookmark(postId: postId);
  }
}

// lib/features/feed/domain/usecases/share_post_usecase.dart
class SharePostUseCase {
  final FeedRepository repository;

  SharePostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(SharePostParams params) async {
    return await repository.sharePost(
      postId: params.postId,
      comment: params.comment,
    );
  }
}

class SharePostParams {
  final String postId;
  final String? comment;

  SharePostParams({
    required this.postId,
    this.comment,
  });
}

// lib/features/feed/domain/usecases/report_post_usecase.dart
class ReportPostUseCase {
  final FeedRepository repository;

  ReportPostUseCase(this.repository);

  Future<Either<Failure, void>> call(ReportPostParams params) async {
    return await repository.reportPost(
      postId: params.postId,
      reason: params.reason,
      description: params.description,
    );
  }
}

class ReportPostParams {
  final String postId;
  final String reason;
  final String? description;

  ReportPostParams({
    required this.postId,
    required this.reason,
    this.description,
  });
}

// lib/features/feed/domain/usecases/record_interaction_usecase.dart
class RecordInteractionUseCase {
  final FeedRepository repository;

  RecordInteractionUseCase(this.repository);

  Future<Either<Failure, void>> call(RecordInteractionParams params) async {
    return await repository.recordInteraction(
      postId: params.postId,
      interactionType: params.interactionType,
      source: params.source,
      timeSpent: params.timeSpent,
    );
  }
}

class RecordInteractionParams {
  final String postId;
  final String interactionType;
  final String source;
  final int? timeSpent;

  RecordInteractionParams({
    required this.postId,
    required this.interactionType,
    required this.source,
    this.timeSpent,
  });
}

// lib/features/feed/domain/usecases/refresh_feed_usecase.dart
class RefreshFeedUseCase {
  final FeedRepository repository;

  RefreshFeedUseCase(this.repository);

  Future<Either<Failure, void>> call(FeedType feedType) async {
    return await repository.refreshFeed(feedType: feedType);
  }
}
