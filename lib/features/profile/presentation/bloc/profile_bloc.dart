import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/core/utils/logger.dart';

import '../../domain/usecases/follow_user_usecase.dart';
import '../../domain/usecases/get_follow_status_usecase.dart';
import '../../domain/usecases/get_user_media_usecase.dart';
import '../../domain/usecases/get_user_posts_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/get_user_stats_usecase.dart';
import '../../domain/usecases/unfollow_user_usecase.dart';
import '../../data/repositories/profile_repository_impl.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfile;
  final GetUserPostsUseCase getUserPosts;
  final GetUserMediaUseCase getUserMedia;
  final FollowUserUseCase followUser;
  final UnfollowUserUseCase unfollowUser;
  final GetFollowStatusUseCase getFollowStatus;
  final GetUserStatsUseCase getUserStats;
  final String? Function() getCurrentUserId;

  ProfileBloc({
    required this.getUserProfile,
    required this.getUserPosts,
    required this.getUserMedia,
    required this.followUser,
    required this.unfollowUser,
    required this.getFollowStatus,
    required this.getUserStats,
    required this.getCurrentUserId,
  }) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
    on<ProfileFollowRequested>(_onProfileFollowRequested);
    on<ProfileUnfollowRequested>(_onProfileUnfollowRequested);
    on<ProfileLoadMorePostsRequested>(_onProfileLoadMorePostsRequested);
    on<ProfileLoadMoreMediaRequested>(_onProfileLoadMoreMediaRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }
  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      hasError: false,
    ));

    try {
      // Get current user ID
      final currentUserId = getCurrentUserId();
      AppLogger.debug('Debug - Current User ID: $currentUserId');
      AppLogger.debug('Debug - Requested User ID: ${event.userId}');

      // Check if it's own profile
      final isOwnProfile =
          currentUserId != null && currentUserId == event.userId;
      AppLogger.debug('Debug - Is Own Profile: $isOwnProfile');

      // Load user profile
      final profileResult = await getUserProfile(event.userId);

      await profileResult.fold(
        (failure) async {
          String errorMessage = failure.message;
          ProfileErrorType errorType = ProfileErrorType.general;

          // Handle specific error types
          if (failure is PrivacyFailure) {
            errorType = ProfileErrorType.private;
            errorMessage = 'This profile is private';
          } else if (failure is SuspendedAccountFailure) {
            errorType = ProfileErrorType.suspended;
            errorMessage = 'This account has been suspended';
          } else if (failure is NotFoundFailure) {
            errorType = ProfileErrorType.notFound;
            errorMessage = 'User not found';
          } else if (failure is AuthenticationFailure) {
            errorType = ProfileErrorType.authRequired;
            errorMessage = 'Please log in to view this profile';
          }

          emit(state.copyWith(
            isLoading: false,
            hasError: true,
            errorMessage: errorMessage,
            errorType: errorType,
          ));
        },
        (user) async {
          emit(state.copyWith(
            user: user,
            isOwnProfile: isOwnProfile,
          ));

          AppLogger.debug('Debug - User loaded: ${user.username}');
          AppLogger.debug('Debug - User is private: ${user.isPrivate}');

          // Load additional data based on profile accessibility
          // For public profiles or own profile, load all data
          // For private profiles that user doesn't follow, only load follow status
          final canViewContent = isOwnProfile || !user.isPrivate;
          AppLogger.debug('Debug - Can view content: $canViewContent');

          if (canViewContent) {
            AppLogger.debug('Debug - Loading all profile data...');
            await Future.wait([
              _loadUserStats(user.id, emit),
              _loadFollowStatus(user.id, emit, isOwnProfile),
              _loadUserPosts(user.id, emit, isInitial: true),
              _loadUserMedia(user.id, emit, isInitial: true),
            ]);
          } else {
            AppLogger.debug('Debug - Loading limited profile data...');
            // For private profiles, only load follow status if we have a current user
            if (currentUserId != null) {
              await _loadFollowStatus(user.id, emit, isOwnProfile);
            }
          }

          emit(state.copyWith(
            isLoading: false,
            canViewContent: canViewContent,
          ));
        },
      );
    } catch (e) {
      AppLogger.debug('Debug - Error in profile load: $e');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'An unexpected error occurred: $e',
      ));
    }
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(isRefreshing: true));

    try {
      // Reload user profile first
      final profileResult = await getUserProfile(state.user!.id);

      await profileResult.fold(
        (failure) async {
          emit(state.copyWith(
            isRefreshing: false,
            errorMessage: failure.message,
          ));
        },
        (user) async {
          emit(state.copyWith(user: user));

          // Refresh all data if profile is accessible
          if (!user.isPrivate || state.isOwnProfile) {
            await Future.wait([
              _loadUserStats(state.user!.id, emit),
              _loadFollowStatus(state.user!.id, emit, state.isOwnProfile),
              _loadUserPosts(state.user!.id, emit, isRefresh: true),
              _loadUserMedia(state.user!.id, emit, isRefresh: true),
            ]);
          }

          emit(state.copyWith(isRefreshing: false));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh profile: $e',
      ));
    }
  }

  Future<void> _onProfileFollowRequested(
    ProfileFollowRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.followStatus == null || state.isOwnProfile) return;

    emit(state.copyWith(isFollowLoading: true));

    final result = await followUser(event.userId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isFollowLoading: false,
          errorMessage: failure.message,
        ));
      },
      (followStatus) {
        emit(state.copyWith(
          isFollowLoading: false,
          followStatus: followStatus,
          // Update follower count optimistically only if not pending
          user: followStatus.isFollowing && !followStatus.isPending
              ? state.user?.copyWith(
                  followersCount: state.user!.followersCount + 1,
                )
              : state.user,
        ));
      },
    );
  }

  Future<void> _onProfileUnfollowRequested(
    ProfileUnfollowRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.followStatus == null || state.isOwnProfile) return;

    emit(state.copyWith(isFollowLoading: true));

    final result = await unfollowUser(event.userId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isFollowLoading: false,
          errorMessage: failure.message,
        ));
      },
      (followStatus) {
        emit(state.copyWith(
          isFollowLoading: false,
          followStatus: followStatus,
          // Update follower count optimistically
          user: state.user?.copyWith(
            followersCount: (state.user!.followersCount - 1)
                .clamp(0, double.infinity)
                .toInt(),
          ),
        ));
      },
    );
  }

  Future<void> _onProfileLoadMorePostsRequested(
    ProfileLoadMorePostsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isLoadingPosts || !state.hasMorePosts) return;

    // Don't load posts for private profiles unless it's own profile
    if (state.user?.isPrivate == true && !state.isOwnProfile) return;

    await _loadUserPosts(event.userId, emit, isLoadMore: true);
  }

  Future<void> _onProfileLoadMoreMediaRequested(
    ProfileLoadMoreMediaRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isLoadingMedia || !state.hasMoreMedia) return;

    // Don't load media for private profiles unless it's own profile
    if (state.user?.isPrivate == true && !state.isOwnProfile) return;

    await _loadUserMedia(event.userId, emit, isLoadMore: true);
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      user: event.updatedUser,
    ));
  }

  // Helper methods
  Future<void> _loadUserStats(
    String userId,
    Emitter<ProfileState> emit,
  ) async {
    final result = await getUserStats(userId);
    result.fold(
      (failure) {
        // Don't emit error for stats failure, just log it
        AppLogger.debug('Failed to load user stats: ${failure.message}');
      },
      (stats) {
        emit(state.copyWith(stats: stats));
      },
    );
  }

  Future<void> _loadFollowStatus(
    String userId,
    Emitter<ProfileState> emit,
    bool isOwnProfile,
  ) async {
    if (isOwnProfile) return;

    final result = await getFollowStatus(userId);
    result.fold(
      (failure) {
        // Don't emit error for follow status failure
        AppLogger.debug('Failed to load follow status: ${failure.message}');
      },
      (followStatus) {
        emit(state.copyWith(followStatus: followStatus));
      },
    );
  }

  Future<void> _loadUserPosts(
    String userId,
    Emitter<ProfileState> emit, {
    bool isInitial = false,
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    AppLogger.debug('Debug - Loading posts for user: $userId');
    AppLogger.debug(
        'Debug - Is initial: $isInitial, Is refresh: $isRefresh, Is load more: $isLoadMore');

    if (isInitial || isRefresh) {
      emit(state.copyWith(
        isLoadingPosts: true,
        posts: isRefresh ? [] : state.posts,
        postsPage: 0,
        hasMorePosts: true,
      ));
    } else if (isLoadMore) {
      emit(state.copyWith(isLoadingPosts: true));
    }

    final page = isLoadMore ? state.postsPage + 1 : 0;
    AppLogger.debug('Debug - Loading posts page: $page');

    final result = await getUserPosts(GetUserPostsParams(
      userId: userId,
      page: page,
      limit: 20,
    ));

    result.fold(
      (failure) {
        AppLogger.debug('Debug - Failed to load posts: ${failure.message}');
        emit(state.copyWith(
          isLoadingPosts: false,
          errorMessage: isInitial ? failure.message : null,
        ));
      },
      (newPosts) {
        AppLogger.debug('Debug - Loaded ${newPosts.length} posts');
        final allPosts =
            isInitial || isRefresh ? newPosts : [...state.posts, ...newPosts];

        AppLogger.debug('Debug - Total posts after load: ${allPosts.length}');

        emit(state.copyWith(
          isLoadingPosts: false,
          posts: allPosts,
          postsPage: page,
          hasMorePosts: newPosts.length >= 20,
        ));
      },
    );
  }

  Future<void> _loadUserMedia(
    String userId,
    Emitter<ProfileState> emit, {
    bool isInitial = false,
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    if (isInitial || isRefresh) {
      emit(state.copyWith(
        isLoadingMedia: true,
        media: isRefresh ? [] : state.media,
        mediaPage: 0,
        hasMoreMedia: true,
      ));
    } else if (isLoadMore) {
      emit(state.copyWith(isLoadingMedia: true));
    }

    final page = isLoadMore ? state.mediaPage + 1 : 0;
    final result = await getUserMedia(GetUserMediaParams(
      userId: userId,
      page: page,
      limit: 20,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoadingMedia: false,
          errorMessage: isInitial ? failure.message : null,
        ));
      },
      (newMedia) {
        final allMedia =
            isInitial || isRefresh ? newMedia : [...state.media, ...newMedia];

        emit(state.copyWith(
          isLoadingMedia: false,
          media: allMedia,
          mediaPage: page,
          hasMoreMedia: newMedia.length >= 20,
        ));
      },
    );
  }
}

// Add enum for different error types
enum ProfileErrorType {
  general,
  private,
  suspended,
  notFound,
  authRequired,
}
