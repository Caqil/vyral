// lib/features/profile/presentation/bloc/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/follow_user_usecase.dart';
import '../../domain/usecases/get_follow_status_usecase.dart';
import '../../domain/usecases/get_user_media_usecase.dart';
import '../../domain/usecases/get_user_posts_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/get_user_stats_usecase.dart';
import '../../domain/usecases/unfollow_user_usecase.dart';
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

  ProfileBloc({
    required this.getUserProfile,
    required this.getUserPosts,
    required this.getUserMedia,
    required this.followUser,
    required this.unfollowUser,
    required this.getFollowStatus,
    required this.getUserStats,
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
    ));

    try {
      // Load user profile
      final profileResult = await getUserProfile(event.userId);

      await profileResult.fold(
        (failure) async {
          emit(state.copyWith(
            isLoading: false,
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (user) async {
          // Check if it's own profile
          final isOwnProfile =
              user.id == 'current_user_id'; // Get from auth state

          emit(state.copyWith(
            user: user,
            isOwnProfile: isOwnProfile,
          ));

          // Load additional data concurrently
          await Future.wait([
            _loadUserStats(user.id, emit),
            _loadFollowStatus(user.id, emit, isOwnProfile),
            _loadUserPosts(user.id, emit, isInitial: true),
            _loadUserMedia(user.id, emit, isInitial: true),
          ]);

          emit(state.copyWith(
            isLoading: false,
          ));
        },
      );
    } catch (e) {
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
      // Refresh all data
      await Future.wait([
        _loadUserStats(state.user!.id, emit),
        _loadFollowStatus(state.user!.id, emit, state.isOwnProfile),
        _loadUserPosts(state.user!.id, emit, isRefresh: true),
        _loadUserMedia(state.user!.id, emit, isRefresh: true),
      ]);

      emit(state.copyWith(isRefreshing: false));
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
    if (state.followStatus == null) return;

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
          // Update follower count optimistically
          user: state.user?.copyWith(
            followersCount: state.user!.followersCount + 1,
          ),
        ));
      },
    );
  }

  Future<void> _onProfileUnfollowRequested(
    ProfileUnfollowRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.followStatus == null) return;

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
            followersCount: state.user!.followersCount - 1,
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

    await _loadUserPosts(event.userId, emit, isLoadMore: true);
  }

  Future<void> _onProfileLoadMoreMediaRequested(
    ProfileLoadMoreMediaRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isLoadingMedia || !state.hasMoreMedia) return;

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
    final result = await getUserPosts(GetUserPostsParams(
      userId: userId,
      page: page,
      limit: 20,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoadingPosts: false,
          errorMessage: isInitial ? failure.message : null,
        ));
      },
      (newPosts) {
        final allPosts =
            isInitial || isRefresh ? newPosts : [...state.posts, ...newPosts];

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
