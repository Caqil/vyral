// lib/features/feed/presentation/bloc/feed_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/feed_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/feed_repository.dart';

enum FeedStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  refreshing,
  error,
}

class FeedState extends Equatable {
  final FeedStatus status;
  final FeedEntity? feed;
  final List<PostEntity> posts;
  final FeedType currentFeedType;
  final String? errorMessage;
  final bool hasReachedMax;
  final bool isRefreshing;
  final int currentPage;
  final Set<String> likedPosts;
  final Set<String> bookmarkedPosts;
  final Map<String, bool> postLoadingStates;

  const FeedState({
    this.status = FeedStatus.initial,
    this.feed,
    this.posts = const [],
    this.currentFeedType = FeedType.personal,
    this.errorMessage,
    this.hasReachedMax = false,
    this.isRefreshing = false,
    this.currentPage = 0,
    this.likedPosts = const {},
    this.bookmarkedPosts = const {},
    this.postLoadingStates = const {},
  });

  FeedState copyWith({
    FeedStatus? status,
    FeedEntity? feed,
    List<PostEntity>? posts,
    FeedType? currentFeedType,
    String? errorMessage,
    bool? hasReachedMax,
    bool? isRefreshing,
    int? currentPage,
    Set<String>? likedPosts,
    Set<String>? bookmarkedPosts,
    Map<String, bool>? postLoadingStates,
  }) {
    return FeedState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      posts: posts ?? this.posts,
      currentFeedType: currentFeedType ?? this.currentFeedType,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentPage: currentPage ?? this.currentPage,
      likedPosts: likedPosts ?? this.likedPosts,
      bookmarkedPosts: bookmarkedPosts ?? this.bookmarkedPosts,
      postLoadingStates: postLoadingStates ?? this.postLoadingStates,
    );
  }

  FeedState clearError() {
    return copyWith(errorMessage: null);
  }

  FeedState setPostLoading(String postId, bool isLoading) {
    final newLoadingStates = Map<String, bool>.from(postLoadingStates);
    if (isLoading) {
      newLoadingStates[postId] = true;
    } else {
      newLoadingStates.remove(postId);
    }
    return copyWith(postLoadingStates: newLoadingStates);
  }

  FeedState updatePost(PostEntity updatedPost) {
    final updatedPosts = posts.map((post) {
      if (post.id == updatedPost.id) {
        return updatedPost;
      }
      return post;
    }).toList();

    // Update liked/bookmarked sets
    final newLikedPosts = Set<String>.from(likedPosts);
    final newBookmarkedPosts = Set<String>.from(bookmarkedPosts);

    if (updatedPost.isLiked) {
      newLikedPosts.add(updatedPost.id);
    } else {
      newLikedPosts.remove(updatedPost.id);
    }

    if (updatedPost.isBookmarked) {
      newBookmarkedPosts.add(updatedPost.id);
    } else {
      newBookmarkedPosts.remove(updatedPost.id);
    }

    return copyWith(
      posts: updatedPosts,
      likedPosts: newLikedPosts,
      bookmarkedPosts: newBookmarkedPosts,
    );
  }

  @override
  List<Object?> get props => [
        status,
        feed,
        posts,
        currentFeedType,
        errorMessage,
        hasReachedMax,
        isRefreshing,
        currentPage,
        likedPosts,
        bookmarkedPosts,
        postLoadingStates,
      ];

  // Helper getters
  bool get isLoading => status == FeedStatus.loading;
  bool get isLoadingMore => status == FeedStatus.loadingMore;
  bool get isLoaded => status == FeedStatus.loaded;
  bool get hasError => errorMessage != null;
  bool get isEmpty => posts.isEmpty && isLoaded;
  bool get canLoadMore => !hasReachedMax && !isLoadingMore && !isRefreshing;

  bool isPostLiked(String postId) => likedPosts.contains(postId);
  bool isPostBookmarked(String postId) => bookmarkedPosts.contains(postId);
  bool isPostLoading(String postId) => postLoadingStates[postId] ?? false;
}
