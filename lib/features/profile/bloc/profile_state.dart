import 'package:vyral/features/profile/domain/entities/user_entity.dart';
import '../domain/entities/follow_status_entity.dart';
import '../domain/entities/media_entity.dart';
import '../domain/entities/post_entity.dart';
import '../domain/entities/story_highlight_entity.dart';
import '../domain/entities/user_stats_entity.dart';
import 'profile_bloc.dart';

class ProfileState {
  final UserEntity? user;
  final UserStatsEntity? stats;
  final FollowStatusEntity? followStatus;
  final List<PostEntity> posts;
  final List<MediaEntity> media;
  final List<StoryHighlightEntity> highlights;
  final bool isOwnProfile;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingPosts;
  final bool isLoadingMedia;
  final bool isFollowLoading;
  final bool isFollowStatusLoading; // NEW: Track follow status loading
  final bool hasError;
  final String? errorMessage;
  final ProfileErrorType? errorType;
  final int postsPage;
  final int mediaPage;
  final bool hasMorePosts;
  final bool hasMoreMedia;
  final bool canViewContent;

  const ProfileState({
    this.user,
    this.stats,
    this.followStatus,
    this.posts = const [],
    this.media = const [],
    this.highlights = const [],
    this.isOwnProfile = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingPosts = false,
    this.isLoadingMedia = false,
    this.isFollowLoading = false,
    this.isFollowStatusLoading = false, // NEW
    this.hasError = false,
    this.errorMessage,
    this.errorType,
    this.postsPage = 0,
    this.mediaPage = 0,
    this.hasMorePosts = true,
    this.hasMoreMedia = true,
    this.canViewContent = true,
  });

  ProfileState copyWith({
    UserEntity? user,
    UserStatsEntity? stats,
    FollowStatusEntity? followStatus,
    List<PostEntity>? posts,
    List<MediaEntity>? media,
    List<StoryHighlightEntity>? highlights,
    bool? isOwnProfile,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingPosts,
    bool? isLoadingMedia,
    bool? isFollowLoading,
    bool? isFollowStatusLoading, // NEW
    bool? hasError,
    String? errorMessage,
    ProfileErrorType? errorType,
    int? postsPage,
    int? mediaPage,
    bool? hasMorePosts,
    bool? hasMoreMedia,
    bool? canViewContent,
  }) {
    return ProfileState(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      followStatus: followStatus ?? this.followStatus,
      posts: posts ?? this.posts,
      media: media ?? this.media,
      highlights: highlights ?? this.highlights,
      isOwnProfile: isOwnProfile ?? this.isOwnProfile,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isLoadingMedia: isLoadingMedia ?? this.isLoadingMedia,
      isFollowLoading: isFollowLoading ?? this.isFollowLoading,
      isFollowStatusLoading:
          isFollowStatusLoading ?? this.isFollowStatusLoading, // NEW
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      errorType: errorType ?? this.errorType,
      postsPage: postsPage ?? this.postsPage,
      mediaPage: mediaPage ?? this.mediaPage,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      hasMoreMedia: hasMoreMedia ?? this.hasMoreMedia,
      canViewContent: canViewContent ?? this.canViewContent,
    );
  }

  // Helper getters
  bool get isPrivateProfile => user?.isPrivate == true && !isOwnProfile;
  bool get canViewPosts =>
      isOwnProfile ||
      user?.isPrivate != true ||
      (followStatus?.isFollowing == true);
  bool get canViewFollowers =>
      isOwnProfile ||
      user?.isPrivate != true ||
      (followStatus?.isFollowing == true);
  bool get canViewFollowing =>
      isOwnProfile ||
      user?.isPrivate != true ||
      (followStatus?.isFollowing == true);
  bool get canViewStats => isOwnProfile || user?.isPrivate != true;
  bool get showFollowButton => !isOwnProfile && user != null;
  bool get showMessageButton =>
      !isOwnProfile && user != null && (followStatus?.canMessage == true);

  String get profileAccessibilityText {
    if (isOwnProfile) return 'Your profile';
    if (user?.isPrivate == true) {
      if (followStatus?.isFollowing == true) {
        return 'Private profile (following)';
      } else if (followStatus?.isPending == true) {
        return 'Private profile (request pending)';
      } else {
        return 'Private profile';
      }
    }
    return 'Public profile';
  }

  String get followButtonText {
    if (followStatus?.isPending == true) {
      return 'Requested';
    } else if (followStatus?.isFollowing == true) {
      return 'Following';
    } else {
      return user?.isPrivate == true ? 'Request' : 'Follow';
    }
  }

  // NEW: Check if follow status has been determined
  bool get isFollowStatusDetermined =>
      isOwnProfile || (!isFollowStatusLoading && followStatus != null);
}
