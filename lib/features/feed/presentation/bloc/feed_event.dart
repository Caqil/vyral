// lib/features/feed/presentation/bloc/feed_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/repositories/feed_repository.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends FeedEvent {
  final FeedType feedType;
  final bool refresh;

  const FeedLoadRequested({
    required this.feedType,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [feedType, refresh];
}

class FeedRefreshRequested extends FeedEvent {
  final FeedType? feedType;

  const FeedRefreshRequested({this.feedType});

  @override
  List<Object?> get props => [feedType];
}

class FeedLoadMoreRequested extends FeedEvent {
  const FeedLoadMoreRequested();
}

class FeedTypeChanged extends FeedEvent {
  final FeedType feedType;

  const FeedTypeChanged({required this.feedType});

  @override
  List<Object?> get props => [feedType];
}

class PostLikeToggled extends FeedEvent {
  final String postId;
  final bool isLiked;
  final String reactionType;

  const PostLikeToggled({
    required this.postId,
    required this.isLiked,
    this.reactionType = 'like',
  });

  @override
  List<Object?> get props => [postId, isLiked, reactionType];
}

class PostBookmarkToggled extends FeedEvent {
  final String postId;
  final bool isBookmarked;

  const PostBookmarkToggled({
    required this.postId,
    required this.isBookmarked,
  });

  @override
  List<Object?> get props => [postId, isBookmarked];
}

class PostShared extends FeedEvent {
  final String postId;
  final String? comment;

  const PostShared({
    required this.postId,
    this.comment,
  });

  @override
  List<Object?> get props => [postId, comment];
}

class PostReported extends FeedEvent {
  final String postId;
  final String reason;
  final String? description;

  const PostReported({
    required this.postId,
    required this.reason,
    this.description,
  });

  @override
  List<Object?> get props => [postId, reason, description];
}

class PostInteractionRecorded extends FeedEvent {
  final String postId;
  final String interactionType;
  final String source;
  final int? timeSpent;

  const PostInteractionRecorded({
    required this.postId,
    required this.interactionType,
    required this.source,
    this.timeSpent,
  });

  @override
  List<Object?> get props => [postId, interactionType, source, timeSpent];
}

class PostViewed extends FeedEvent {
  final String postId;
  final String source;
  final int? timeSpent;

  const PostViewed({
    required this.postId,
    required this.source,
    this.timeSpent,
  });

  @override
  List<Object?> get props => [postId, source, timeSpent];
}

class FeedErrorCleared extends FeedEvent {
  const FeedErrorCleared();
}

class FeedRetryRequested extends FeedEvent {
  const FeedRetryRequested();
}

class PostUpdated extends FeedEvent {
  final String postId;
  final Map<String, dynamic> updates;

  const PostUpdated({
    required this.postId,
    required this.updates,
  });

  @override
  List<Object?> get props => [postId, updates];
}

class FeedCacheCleared extends FeedEvent {
  final FeedType? feedType;

  const FeedCacheCleared({this.feedType});

  @override
  List<Object?> get props => [feedType];
}
