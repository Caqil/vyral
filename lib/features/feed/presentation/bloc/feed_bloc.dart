// lib/features/feed/presentation/bloc/feed_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/pagination_model.dart';
import '../../domain/entities/feed_entity.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedUseCase getFeedUseCase;
  final LikePostUseCase likePostUseCase;
  final UnlikePostUseCase unlikePostUseCase;
  final BookmarkPostUseCase bookmarkPostUseCase;
  final RemoveBookmarkUseCase removeBookmarkUseCase;
  final SharePostUseCase sharePostUseCase;
  final ReportPostUseCase reportPostUseCase;
  final RecordInteractionUseCase recordInteractionUseCase;
  final RefreshFeedUseCase refreshFeedUseCase;
  final FeedRepository feedRepository;

  static const int _pageSize = 20;

  FeedBloc({
    required this.getFeedUseCase,
    required this.likePostUseCase,
    required this.unlikePostUseCase,
    required this.bookmarkPostUseCase,
    required this.removeBookmarkUseCase,
    required this.sharePostUseCase,
    required this.reportPostUseCase,
    required this.recordInteractionUseCase,
    required this.refreshFeedUseCase,
    required this.feedRepository,
  }) : super(const FeedState()) {
    on<FeedLoadRequested>(_onFeedLoadRequested);
    on<FeedRefreshRequested>(_onFeedRefreshRequested);
    on<FeedLoadMoreRequested>(_onFeedLoadMoreRequested);
    on<FeedTypeChanged>(_onFeedTypeChanged);
    on<PostLikeToggled>(_onPostLikeToggled);
    on<PostBookmarkToggled>(_onPostBookmarkToggled);
    on<PostShared>(_onPostShared);
    on<PostReported>(_onPostReported);
    on<PostInteractionRecorded>(_onPostInteractionRecorded);
    on<PostViewed>(_onPostViewed);
    on<FeedErrorCleared>(_onFeedErrorCleared);
    on<FeedRetryRequested>(_onFeedRetryRequested);
    on<PostUpdated>(_onPostUpdated);
    on<FeedCacheCleared>(_onFeedCacheCleared);
  }

  Future<void> _onFeedLoadRequested(
    FeedLoadRequested event,
    Emitter<FeedState> emit,
  ) async {
    // If refreshing or changing feed type, start fresh
    if (event.refresh || event.feedType != state.currentFeedType) {
      emit(state.copyWith(
        status: FeedStatus.loading,
        currentFeedType: event.feedType,
        currentPage: 0,
        hasReachedMax: false,
        errorMessage: null,
      ));

      await _loadFeedData(emit, event.feedType, 0, event.refresh);
    } else if (state.posts.isEmpty) {
      // First time loading
      emit(state.copyWith(
        status: FeedStatus.loading,
        currentFeedType: event.feedType,
        errorMessage: null,
      ));

      await _loadFeedData(emit, event.feedType, 0, event.refresh);
    }
  }

  Future<void> _onFeedRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    final feedType = event.feedType ?? state.currentFeedType;

    emit(state.copyWith(
      status: FeedStatus.refreshing,
      isRefreshing: true,
      errorMessage: null,
    ));

    // Refresh feed algorithm/cache
    final refreshResult = await refreshFeedUseCase(feedType);
    refreshResult.fold(
      (failure) {
        // Continue even if refresh fails
      },
      (_) {
        // Refresh successful
      },
    );

    await _loadFeedData(emit, feedType, 0, true);
  }

  Future<void> _onFeedLoadMoreRequested(
    FeedLoadMoreRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(status: FeedStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    await _loadFeedData(emit, state.currentFeedType, nextPage, false);
  }

  Future<void> _onFeedTypeChanged(
    FeedTypeChanged event,
    Emitter<FeedState> emit,
  ) async {
    if (event.feedType == state.currentFeedType) return;

    emit(state.copyWith(
      status: FeedStatus.loading,
      currentFeedType: event.feedType,
      posts: [],
      currentPage: 0,
      hasReachedMax: false,
      errorMessage: null,
    ));

    await _loadFeedData(emit, event.feedType, 0, false);
  }

  Future<void> _onPostLikeToggled(
    PostLikeToggled event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.setPostLoading(event.postId, true));

    try {
      if (event.isLiked) {
        // Unlike the post
        final result = await unlikePostUseCase(event.postId);
        result.fold(
          (failure) => emit(state.copyWith(
            errorMessage: failure.message,
            postLoadingStates: Map.from(state.postLoadingStates)
              ..remove(event.postId),
          )),
          (updatedPost) => emit(state
              .updatePost(updatedPost)
              .setPostLoading(event.postId, false)),
        );
      } else {
        // Like the post
        final result = await likePostUseCase(
          LikePostParams(
              postId: event.postId, reactionType: event.reactionType),
        );
        result.fold(
          (failure) => emit(state.copyWith(
            errorMessage: failure.message,
            postLoadingStates: Map.from(state.postLoadingStates)
              ..remove(event.postId),
          )),
          (updatedPost) => emit(state
              .updatePost(updatedPost)
              .setPostLoading(event.postId, false)),
        );
      }

      // Record interaction
      add(PostInteractionRecorded(
        postId: event.postId,
        interactionType: event.isLiked ? 'unlike' : 'like',
        source: 'feed',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update like status',
        postLoadingStates: Map.from(state.postLoadingStates)
          ..remove(event.postId),
      ));
    }
  }

  Future<void> _onPostBookmarkToggled(
    PostBookmarkToggled event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.setPostLoading(event.postId, true));

    try {
      if (event.isBookmarked) {
        // Remove bookmark
        final result = await removeBookmarkUseCase(event.postId);
        result.fold(
          (failure) => emit(state.copyWith(
            errorMessage: failure.message,
            postLoadingStates: Map.from(state.postLoadingStates)
              ..remove(event.postId),
          )),
          (updatedPost) => emit(state
              .updatePost(updatedPost)
              .setPostLoading(event.postId, false)),
        );
      } else {
        // Add bookmark
        final result = await bookmarkPostUseCase(event.postId);
        result.fold(
          (failure) => emit(state.copyWith(
            errorMessage: failure.message,
            postLoadingStates: Map.from(state.postLoadingStates)
              ..remove(event.postId),
          )),
          (updatedPost) => emit(state
              .updatePost(updatedPost)
              .setPostLoading(event.postId, false)),
        );
      }

      // Record interaction
      add(PostInteractionRecorded(
        postId: event.postId,
        interactionType: event.isBookmarked ? 'unbookmark' : 'bookmark',
        source: 'feed',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update bookmark status',
        postLoadingStates: Map.from(state.postLoadingStates)
          ..remove(event.postId),
      ));
    }
  }

  Future<void> _onPostShared(
    PostShared event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.setPostLoading(event.postId, true));

    final result = await sharePostUseCase(
      SharePostParams(postId: event.postId, comment: event.comment),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
        postLoadingStates: Map.from(state.postLoadingStates)
          ..remove(event.postId),
      )),
      (updatedPost) {
        emit(state.updatePost(updatedPost).setPostLoading(event.postId, false));

        // Record interaction
        add(PostInteractionRecorded(
          postId: event.postId,
          interactionType: 'share',
          source: 'feed',
        ));
      },
    );
  }

  Future<void> _onPostReported(
    PostReported event,
    Emitter<FeedState> emit,
  ) async {
    final result = await reportPostUseCase(
      ReportPostParams(
        postId: event.postId,
        reason: event.reason,
        description: event.description,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(errorMessage: null)),
    );
  }

  Future<void> _onPostInteractionRecorded(
    PostInteractionRecorded event,
    Emitter<FeedState> emit,
  ) async {
    // Record interaction asynchronously - don't block UI
    await recordInteractionUseCase(
      RecordInteractionParams(
        postId: event.postId,
        interactionType: event.interactionType,
        source: event.source,
        timeSpent: event.timeSpent,
      ),
    );
  }

  Future<void> _onPostViewed(
    PostViewed event,
    Emitter<FeedState> emit,
  ) async {
    // Record view interaction
    add(PostInteractionRecorded(
      postId: event.postId,
      interactionType: 'view',
      source: event.source,
      timeSpent: event.timeSpent,
    ));
  }

  Future<void> _onFeedErrorCleared(
    FeedErrorCleared event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.clearError());
  }

  Future<void> _onFeedRetryRequested(
    FeedRetryRequested event,
    Emitter<FeedState> emit,
  ) async {
    add(FeedLoadRequested(feedType: state.currentFeedType, refresh: true));
  }

  Future<void> _onPostUpdated(
    PostUpdated event,
    Emitter<FeedState> emit,
  ) async {
    final updatedPosts = state.posts.map((post) {
      if (post.id == event.postId) {
        // Apply updates to the post
        // This would typically involve creating a new post with updated fields
        // For now, we'll just return the existing post
        return post;
      }
      return post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));
  }

  Future<void> _onFeedCacheCleared(
    FeedCacheCleared event,
    Emitter<FeedState> emit,
  ) async {
    final result = await feedRepository.cacheFeed(
      type: event.feedType ?? state.currentFeedType,
      feed: state.feed ??
          FeedEntity(
            posts: [],
            pagination: PaginationModel(),
            feedType: 'personal',
            lastRefreshed: DateTime.now(),
            hasMore: false,
          ),
    );

    result.fold(
      (failure) => {
        // Handle cache clear failure if needed
      },
      (_) => {
        // Cache cleared successfully
      },
    );
  }

  Future<void> _loadFeedData(
    Emitter<FeedState> emit,
    FeedType feedType,
    int page,
    bool refresh,
  ) async {
    final skip = page * _pageSize;
    final params = GetFeedParams(
      type: feedType,
      limit: _pageSize,
      skip: skip,
      refresh: refresh,
    );

    final result = await getFeedUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FeedStatus.error,
        errorMessage: failure.message,
        isRefreshing: false,
      )),
      (feedEntity) {
        final newPosts = feedEntity.posts;
        final allPosts = page == 0 ? newPosts : [...state.posts, ...newPosts];

        // Update liked and bookmarked sets
        final likedPosts = <String>{};
        final bookmarkedPosts = <String>{};

        for (final post in allPosts) {
          if (post.isLiked) likedPosts.add(post.id);
          if (post.isBookmarked) bookmarkedPosts.add(post.id);
        }

        emit(state.copyWith(
          status: FeedStatus.loaded,
          feed: feedEntity,
          posts: allPosts,
          currentPage: page,
          hasReachedMax: newPosts.length < _pageSize || !feedEntity.hasMore,
          isRefreshing: false,
          errorMessage: null,
          likedPosts: likedPosts,
          bookmarkedPosts: bookmarkedPosts,
        ));
      },
    );
  }

  // Helper method to initialize feed for the first time
  void loadInitialFeed({FeedType feedType = FeedType.personal}) {
    add(FeedLoadRequested(feedType: feedType));
  }

  // Helper method to refresh current feed
  void refreshCurrentFeed() {
    add(const FeedRefreshRequested());
  }

  // Helper method to load more posts
  void loadMorePosts() {
    add(const FeedLoadMoreRequested());
  }

  // Helper method to switch feed type
  void switchFeedType(FeedType feedType) {
    add(FeedTypeChanged(feedType: feedType));
  }

  // Helper method to toggle like on a post
  void togglePostLike(String postId, bool isCurrentlyLiked,
      [String reactionType = 'like']) {
    add(PostLikeToggled(
      postId: postId,
      isLiked: isCurrentlyLiked,
      reactionType: reactionType,
    ));
  }

  // Helper method to toggle bookmark on a post
  void togglePostBookmark(String postId, bool isCurrentlyBookmarked) {
    add(PostBookmarkToggled(
      postId: postId,
      isBookmarked: isCurrentlyBookmarked,
    ));
  }

  // Helper method to share a post
  void sharePost(String postId, [String? comment]) {
    add(PostShared(postId: postId, comment: comment));
  }

  // Helper method to report a post
  void reportPost(String postId, String reason, [String? description]) {
    add(PostReported(
      postId: postId,
      reason: reason,
      description: description,
    ));
  }

  // Helper method to record post view
  void recordPostView(String postId, String source, [int? timeSpent]) {
    add(PostViewed(
      postId: postId,
      source: source,
      timeSpent: timeSpent,
    ));
  }

  // Helper method to clear errors
  void clearError() {
    add(const FeedErrorCleared());
  }

  // Helper method to retry loading
  void retry() {
    add(const FeedRetryRequested());
  }
}
