import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/profile/pages/followers_page.dart';
import '../../features/profile/pages/following_page.dart';
import '../../features/profile/pages/post_detail_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/edit_profile_bloc.dart';
import '../../features/profile/presentation/bloc/followers_bloc.dart';
import '../../features/profile/presentation/bloc/following_bloc.dart';
import '../../features/profile/presentation/bloc/post_detail_bloc.dart';
import '../../main.dart'; // For dependency injection

List<RouteBase> profileRoutes = [
  // Profile routes
  GoRoute(
    path: '/profile/:userId',
    name: 'profile',
    builder: (context, state) {
      final userId = state.pathParameters['userId']!;
      final username = state.uri.queryParameters['username'];

      return BlocProvider(
        create: (context) => _createProfileBloc(),
        child: ProfilePage(
          userId: userId,
          username: username,
        ),
      );
    },
    routes: [
      // Followers page
      GoRoute(
        path: '/followers',
        name: 'followers',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final username = state.uri.queryParameters['username'];

          return BlocProvider(
            create: (context) => _createFollowersBloc(),
            child: FollowersPage(
              userId: userId,
              username: username,
            ),
          );
        },
      ),

      // Following page
      GoRoute(
        path: '/following',
        name: 'following',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final username = state.uri.queryParameters['username'];

          return BlocProvider(
            create: (context) => _createFollowingBloc(),
            child: FollowingPage(
              userId: userId,
              username: username,
            ),
          );
        },
      ),
    ],
  ),

  // Edit profile route (protected - own profile only)
  GoRoute(
    path: '/profile/edit',
    name: 'edit-profile',
    builder: (context, state) {
      return BlocProvider(
        create: (context) => _createEditProfileBloc(),
        child: const EditProfilePage(),
      );
    },
  ),

  // Post detail route
  GoRoute(
    path: '/post/:postId',
    name: 'post-detail',
    builder: (context, state) {
      final postId = state.pathParameters['postId']!;

      return BlocProvider(
        create: (context) => _createPostDetailBloc(),
        child: PostDetailPage(postId: postId),
      );
    },
  ),

  // Username-based profile route (redirects to userId-based route)
  GoRoute(
    path: '/u/:username',
    name: 'profile-by-username',
    redirect: (context, state) async {
      final username = state.pathParameters['username']!;

      // In a real app, you'd fetch the userId for this username
      // For now, we'll assume username = userId
      return '/profile/$username?username=$username';
    },
  ),
];

// Dependency injection helpers
ProfileBloc _createProfileBloc() {
  return ProfileBloc(
    getUserProfile: SocialNetworkApp.getUserProfileUseCase(),
    getUserPosts: SocialNetworkApp.getUserPostsUseCase(),
    getUserMedia: SocialNetworkApp.getUserMediaUseCase(),
    followUser: SocialNetworkApp.getFollowUserUseCase(),
    unfollowUser: SocialNetworkApp.getUnfollowUserUseCase(),
    getFollowStatus: SocialNetworkApp.getFollowStatusUseCase(),
    getUserStats: SocialNetworkApp.getUserStatsUseCase(),
  );
}

EditProfileBloc _createEditProfileBloc() {
  return EditProfileBloc(
    getUserProfile: SocialNetworkApp.getUserProfileUseCase(),
    updateProfile: SocialNetworkApp.getUpdateProfileUseCase(),
    uploadProfilePicture: SocialNetworkApp.getUploadProfilePictureUseCase(),
    uploadCoverPicture: SocialNetworkApp.getUploadCoverPictureUseCase(),
  );
}

FollowersBloc _createFollowersBloc() {
  return FollowersBloc(
    getFollowers: SocialNetworkApp.getFollowersUseCase(),
  );
}

FollowingBloc _createFollowingBloc() {
  return FollowingBloc(
    getFollowing: SocialNetworkApp.getFollowingUseCase(),
    unfollowUser: SocialNetworkApp.getUnfollowUserUseCase(),
  );
}

PostDetailBloc _createPostDetailBloc() {
  return PostDetailBloc(
    getPost: SocialNetworkApp.getPostUseCase(),
    getPostComments: SocialNetworkApp.getPostCommentsUseCase(),
    likePost: SocialNetworkApp.getLikePostUseCase(),
    createComment: SocialNetworkApp.getCreateCommentUseCase(),
    likeComment: SocialNetworkApp.getLikeCommentUseCase(),
  );
}
