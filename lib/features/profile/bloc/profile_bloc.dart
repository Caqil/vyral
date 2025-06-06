import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/core/utils/logger.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';

import '../data/repositories/profile_repository_impl.dart';
import '../domain/entities/follow_status_entity.dart';
import '../domain/usecases/follow_user_usecase.dart';
import '../domain/usecases/get_follow_status_usecase.dart';
import '../domain/usecases/get_user_media_usecase.dart';
import '../domain/usecases/get_user_posts_usecase.dart';
import '../domain/usecases/get_user_profile_usecase.dart';
import '../domain/usecases/get_user_stats_usecase.dart';
import '../domain/usecases/unfollow_user_usecase.dart';
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
    AppLogger.debug('🔄 Loading profile for user: ${event.userId}');

    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      hasError: false,
      followStatus: null, // Reset follow status
      isFollowLoading: false,
    ));

    try {
      final currentUserId = getCurrentUserId();
      final isOwnProfile = currentUserId != null &&
          currentUserId.isNotEmpty &&
          currentUserId == event.userId;

      AppLogger.debug(
          '👤 Current user: $currentUserId, Target user: ${event.userId}');
      AppLogger.debug('🏠 Is own profile: $isOwnProfile');

      // Step 1: Load user profile
      final profileResult = await getUserProfile(event.userId);

      await profileResult.fold(
        (failure) async {
          AppLogger.debug('❌ Failed to load profile: ${failure.message}');
          _handleProfileLoadFailure(failure, emit);
        },
        (user) async {
          AppLogger.debug(
              '✅ Profile loaded: ${user.username} (private: ${user.isPrivate})');

          // Update state with user info immediately
          emit(state.copyWith(
            user: user,
            isOwnProfile: isOwnProfile,
            isLoading: false, // Profile loaded, but still loading follow status
          ));

          // Step 2: For other users, IMMEDIATELY load follow status (Instagram/X behavior)
          if (!isOwnProfile &&
              currentUserId != null &&
              currentUserId.isNotEmpty) {
            AppLogger.debug(
                '🔍 Loading follow status for Instagram/X-like behavior...');

            // Show loading state for follow button
            emit(state.copyWith(isFollowLoading: true));

            await _loadFollowStatusWithImmediate(user.id, emit);
          }

          // Step 3: Determine what content can be viewed based on follow status
          final canViewContent =
              _determineContentVisibility(user, isOwnProfile);
          AppLogger.debug('👁️ Can view content: $canViewContent');

          // Step 4: Load additional data based on visibility
          if (canViewContent) {
            await _loadProfileData(user.id, emit, isOwnProfile);
          }

          emit(state.copyWith(
            canViewContent: canViewContent,
          ));
        },
      );
    } catch (e) {
      AppLogger.debug('💥 Unexpected error in profile load: $e');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'An unexpected error occurred: $e',
      ));
    }
  }

  /// NEW METHOD: Load follow status immediately and handle all scenarios
  Future<void> _loadFollowStatusWithImmediate(
      String userId, Emitter<ProfileState> emit) async {
    try {
      AppLogger.debug('🔄 Fetching follow status from API...');

      final result = await getFollowStatus(userId);

      result.fold(
        (failure) {
          AppLogger.debug(
              '⚠️ Failed to load follow status: ${failure.message}');

          // Handle different failure types
          if (failure.message.contains('404') ||
              failure.message.contains('not found')) {
            // User relationship doesn't exist yet - they are not following
            final defaultFollowStatus = FollowStatusEntity(
              userId: getCurrentUserId() ?? '',
              targetUserId: userId,
              isFollowing: false,
              isFollowedBy: false,
              isPending: false,
              isBlocked: false,
              isMuted: false,
            );

            AppLogger.debug(
                '✅ No relationship exists - defaulting to not following');
            emit(state.copyWith(
              followStatus: defaultFollowStatus,
              isFollowLoading: false,
            ));
          } else {
            // Other errors - still stop loading but don't set follow status
            AppLogger.debug('❌ Follow status API error: ${failure.message}');
            emit(state.copyWith(
              isFollowLoading: false,
              hasError: false, // Don't show error for follow status failure
            ));
          }
        },
        (followStatus) {
          AppLogger.debug(
              '✅ Follow status loaded from API: Following=${followStatus.isFollowing}, Pending=${followStatus.isPending}, Blocked=${followStatus.isBlocked}');

          emit(state.copyWith(
            followStatus: followStatus,
            isFollowLoading: false,
          ));
        },
      );
    } catch (e) {
      AppLogger.debug('💥 Exception loading follow status: $e');

      // Create default "not following" status for exceptions
      final defaultFollowStatus = FollowStatusEntity(
        userId: getCurrentUserId() ?? '',
        targetUserId: userId,
        isFollowing: false,
        isFollowedBy: false,
        isPending: false,
        isBlocked: false,
        isMuted: false,
      );

      emit(state.copyWith(
        followStatus: defaultFollowStatus,
        isFollowLoading: false,
      ));
    }
  }

  void _handleProfileLoadFailure(dynamic failure, Emitter<ProfileState> emit) {
    String errorMessage = failure.message;
    ProfileErrorType errorType = ProfileErrorType.general;

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
  }

  bool _determineContentVisibility(UserEntity user, bool isOwnProfile) {
    // Own profile: always visible
    if (isOwnProfile) return true;

    // Public profile: always visible
    if (!user.isPrivate) return true;

    // Private profile: only if following (check current follow status)
    return state.followStatus?.isFollowing == true;
  }

  Future<void> _loadProfileData(
      String userId, Emitter<ProfileState> emit, bool isOwnProfile) async {
    AppLogger.debug('📊 Loading profile data...');

    await Future.wait([
      _loadUserStats(userId, emit),
      _loadUserPosts(userId, emit, isInitial: true),
      _loadUserMedia(userId, emit, isInitial: true),
    ]);
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(isRefreshing: true));

    try {
      // Reload profile
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

          // Refresh follow status for other users (CRITICAL: Always reload relationship)
          if (!state.isOwnProfile) {
            AppLogger.debug('🔄 Refreshing follow status...');
            emit(state.copyWith(isFollowLoading: true));
            await _loadFollowStatusWithImmediate(state.user!.id, emit);
          }

          // Refresh content if accessible
          final canViewContent =
              _determineContentVisibility(user, state.isOwnProfile);
          if (canViewContent) {
            await _loadProfileData(state.user!.id, emit, state.isOwnProfile);
          }

          emit(state.copyWith(
            isRefreshing: false,
            canViewContent: canViewContent,
          ));
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
    if (state.isOwnProfile) {
      AppLogger.debug('❌ Cannot follow own profile');
      return;
    }

    AppLogger.debug(
        '💙 Instagram-style Follow requested for user ${event.userId}');

    // Step 1: Optimistic update (Instagram behavior)
    final optimisticFollowStatus =
        _createOptimisticFollowStatus(event.userId, isFollowing: true);
    final optimisticUser = _updateFollowerCountOptimistically(1);

    emit(state.copyWith(
      isFollowLoading: true,
      followStatus: optimisticFollowStatus,
      user: optimisticUser,
      hasError: false,
      errorMessage: null,
    ));

    try {
      final result = await followUser(event.userId);

      await result.fold(
        (failure) async {
          AppLogger.debug('❌ Follow failed: ${failure.message}');
          await _handleFollowFailure(failure, event.userId, emit);
        },
        (actualFollowStatus) async {
          AppLogger.debug('✅ Follow successful - syncing with server state');
          await _handleFollowSuccess(actualFollowStatus, emit);
        },
      );
    } catch (e) {
      AppLogger.debug('💥 Follow exception: $e');
      await _handleFollowException(e, event.userId, emit);
    }
  }

  Future<void> _onProfileUnfollowRequested(
    ProfileUnfollowRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isOwnProfile) {
      AppLogger.debug('❌ Cannot unfollow own profile');
      return;
    }

    AppLogger.debug(
        '💔 Instagram-style Unfollow requested for user ${event.userId}');

    // Step 1: Optimistic update (Instagram behavior)
    final optimisticFollowStatus =
        _createOptimisticFollowStatus(event.userId, isFollowing: false);
    final optimisticUser = _updateFollowerCountOptimistically(-1);

    emit(state.copyWith(
      isFollowLoading: true,
      followStatus: optimisticFollowStatus,
      user: optimisticUser,
      hasError: false,
      errorMessage: null,
    ));

    try {
      final result = await unfollowUser(event.userId);

      await result.fold(
        (failure) async {
          AppLogger.debug('❌ Unfollow failed: ${failure.message}');
          await _handleUnfollowFailure(failure, event.userId, emit);
        },
        (actualFollowStatus) async {
          AppLogger.debug('✅ Unfollow successful - syncing with server state');
          await _handleUnfollowSuccess(actualFollowStatus, emit);
        },
      );
    } catch (e) {
      AppLogger.debug('💥 Unfollow exception: $e');
      await _handleUnfollowException(e, event.userId, emit);
    }
  }

  // Helper methods for follow operations
  FollowStatusEntity _createOptimisticFollowStatus(String userId,
      {required bool isFollowing}) {
    final currentUserId = getCurrentUserId() ?? '';
    final isPrivateAccount = state.user?.isPrivate == true;

    return FollowStatusEntity(
      userId: currentUserId,
      targetUserId: userId,
      isFollowing: isFollowing &&
          !isPrivateAccount, // Private accounts go to pending first
      isFollowedBy: state.followStatus?.isFollowedBy ?? false,
      isPending:
          isFollowing && isPrivateAccount, // Private accounts require approval
      isBlocked: false,
      isMuted: state.followStatus?.isMuted ?? false,
      followedAt: isFollowing ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
  }

  UserEntity? _updateFollowerCountOptimistically(int delta) {
    if (state.user == null) return null;

    final newCount =
        (state.user!.followersCount + delta).clamp(0, double.infinity).toInt();
    return state.user!.copyWith(followersCount: newCount);
  }

  Future<void> _handleFollowFailure(
      dynamic failure, String userId, Emitter<ProfileState> emit) async {
    if (failure.message.contains('409') ||
        failure.message.toLowerCase().contains('already following')) {
      // User is already following - sync with server state by reloading follow status
      AppLogger.debug(
          '👍 Already following - reloading actual status from server');
      await _loadFollowStatusWithImmediate(userId, emit);
    } else {
      // Rollback optimistic update
      await _rollbackFollowOperation(userId, emit, failure.message);
    }
  }

  Future<void> _handleUnfollowFailure(
      dynamic failure, String userId, Emitter<ProfileState> emit) async {
    if (failure.message.contains('404') ||
        failure.message.toLowerCase().contains('not following')) {
      // User is not following - sync with server state by reloading follow status
      AppLogger.debug('👎 Not following - reloading actual status from server');
      await _loadFollowStatusWithImmediate(userId, emit);
    } else {
      // Rollback optimistic update
      await _rollbackUnfollowOperation(userId, emit, failure.message);
    }
  }

  Future<void> _handleFollowSuccess(
      FollowStatusEntity actualStatus, Emitter<ProfileState> emit) async {
    // Use the actual server response instead of optimistic update
    final actualUser = state.user?.copyWith(
      followersCount: actualStatus.isFollowing && !actualStatus.isPending
          ? state.user!.followersCount
          : state.user!.followersCount - 1, // Adjust if it's pending
    );

    if (!emit.isDone) {
      emit(state.copyWith(
        isFollowLoading: false,
        followStatus: actualStatus, // Use server response
        user: actualUser,
        hasError: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _handleUnfollowSuccess(
      FollowStatusEntity actualStatus, Emitter<ProfileState> emit) async {
    if (!emit.isDone) {
      emit(state.copyWith(
        isFollowLoading: false,
        followStatus: actualStatus, // Use server response
        hasError: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _handleFollowException(
      dynamic e, String userId, Emitter<ProfileState> emit) async {
    if (e.toString().contains('409') ||
        e.toString().toLowerCase().contains('already following')) {
      // Handle "already following" from exception - reload from server
      AppLogger.debug(
          '👍 Already following (from exception) - reloading from server');
      await _loadFollowStatusWithImmediate(userId, emit);
    } else {
      await _rollbackFollowOperation(userId, emit, 'Network error occurred');
    }
  }

  Future<void> _handleUnfollowException(
      dynamic e, String userId, Emitter<ProfileState> emit) async {
    if (e.toString().contains('409') ||
        e.toString().contains('404') ||
        e.toString().toLowerCase().contains('not following')) {
      // Handle "not following" from exception - reload from server
      AppLogger.debug(
          '👎 Not following (from exception) - reloading from server');
      await _loadFollowStatusWithImmediate(userId, emit);
    } else {
      await _rollbackUnfollowOperation(userId, emit, 'Network error occurred');
    }
  }

  Future<void> _rollbackFollowOperation(
      String userId, Emitter<ProfileState> emit, String errorMessage) async {
    AppLogger.debug('🔄 Rolling back follow operation');

    // Restore previous state
    final previousFollowStatus = state.followStatus?.copyWith(
          isFollowing: false,
          isPending: false,
          updatedAt: DateTime.now(),
        ) ??
        FollowStatusEntity(
          userId: getCurrentUserId() ?? '',
          targetUserId: userId,
          isFollowing: false,
          isFollowedBy: false,
          isPending: false,
          isBlocked: false,
          isMuted: false,
        );

    final restoredUser =
        _updateFollowerCountOptimistically(-1); // Undo the optimistic increment

    if (!emit.isDone) {
      emit(state.copyWith(
        isFollowLoading: false,
        followStatus: previousFollowStatus,
        user: restoredUser,
        hasError: true,
        errorMessage: errorMessage,
      ));
    }

    // Clear error after delay
    _clearErrorAfterDelay(emit);
  }

  Future<void> _rollbackUnfollowOperation(
      String userId, Emitter<ProfileState> emit, String errorMessage) async {
    AppLogger.debug('🔄 Rolling back unfollow operation');

    // Restore previous state
    final previousFollowStatus = state.followStatus?.copyWith(
          isFollowing: true,
          isPending: false,
          updatedAt: DateTime.now(),
        ) ??
        FollowStatusEntity(
          userId: getCurrentUserId() ?? '',
          targetUserId: userId,
          isFollowing: true,
          isFollowedBy: false,
          isPending: false,
          isBlocked: false,
          isMuted: false,
        );

    final restoredUser =
        _updateFollowerCountOptimistically(1); // Undo the optimistic decrement

    if (!emit.isDone) {
      emit(state.copyWith(
        isFollowLoading: false,
        followStatus: previousFollowStatus,
        user: restoredUser,
        hasError: true,
        errorMessage: errorMessage,
      ));
    }

    // Clear error after delay
    _clearErrorAfterDelay(emit);
  }

  void _clearErrorAfterDelay(Emitter<ProfileState> emit) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!emit.isDone) {
        emit(state.copyWith(hasError: false, errorMessage: null));
      }
    });
  }

  // Keep existing methods for load more and other operations...
  Future<void> _onProfileLoadMorePostsRequested(
    ProfileLoadMorePostsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isLoadingPosts || !state.hasMorePosts) return;
    if (state.user?.isPrivate == true && !state.isOwnProfile) return;
    await _loadUserPosts(event.userId, emit, isLoadMore: true);
  }

  Future<void> _onProfileLoadMoreMediaRequested(
    ProfileLoadMoreMediaRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isLoadingMedia || !state.hasMoreMedia) return;
    if (state.user?.isPrivate == true && !state.isOwnProfile) return;
    await _loadUserMedia(event.userId, emit, isLoadMore: true);
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(user: event.updatedUser));
  }

  // Existing helper methods...
  Future<void> _loadUserStats(String userId, Emitter<ProfileState> emit) async {
    final result = await getUserStats(userId);
    result.fold(
      (failure) =>
          AppLogger.debug('Failed to load user stats: ${failure.message}'),
      (stats) => emit(state.copyWith(stats: stats)),
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

enum ProfileErrorType {
  general,
  private,
  suspended,
  notFound,
  authRequired,
}
