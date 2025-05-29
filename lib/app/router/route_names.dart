class RouteNames {
  // Auth routes
  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // Main app routes
  static const String home = '/';
  static const String feed = '/feed';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // User routes
  static const String userProfile = '/user/:userId';
  static const String editProfile = '/profile/edit';
  static const String followers = '/user/:userId/followers';
  static const String following = '/user/:userId/following';

  // Post routes
  static const String createPost = '/post/create';
  static const String postDetail = '/post/:postId';
  static const String editPost = '/post/:postId/edit';

  // Message routes
  static const String messages = '/messages';
  static const String conversation = '/messages/:conversationId';
  static const String createConversation = '/messages/create';

  // Group routes
  static const String groups = '/groups';
  static const String groupDetail = '/group/:groupId';
  static const String createGroup = '/group/create';
  static const String editGroup = '/group/:groupId/edit';

  // Story routes
  static const String stories = '/stories';
  static const String createStory = '/story/create';
  static const String storyDetail = '/story/:storyId';

  // Settings routes
  static const String accountSettings = '/settings/account';
  static const String privacySettings = '/settings/privacy';
  static const String notificationSettings = '/settings/notifications';
  static const String securitySettings = '/settings/security';
  static const String helpSupport = '/settings/help';
}
