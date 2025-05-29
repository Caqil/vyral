// lib/core/constants/api_constants.dart

class ApiConstants {
  // Base URL - Update this to your actual server URL
  // For local development:
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // For production or ngrok (update with your actual URL):
  // static const String baseUrl = 'https://your-ngrok-url.ngrok-free.app/api/v1';
  // static const String baseUrl = 'https://your-production-domain.com/api/v1';

  // Timeout settings
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String sessions = '/auth/sessions';
  static const String checkUser = '/auth/check-user';
  static const String cleanupSessions = '/auth/cleanup-sessions';

  // User endpoints
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String userPrivacySettings = '/users/privacy-settings';
  static const String userNotificationSettings = '/users/notification-settings';
  static const String changePassword = '/users/change-password';
  static const String userSearch = '/users/search';
  static const String userStats = '/users/{id}/stats';
  static const String userSuggestions = '/users/suggestions';
  static const String userActivity = '/users/activity';
  static const String blockUser = '/users/{id}/block';
  static const String blockedUsers = '/users/blocked';
  static const String verifyUserEmail = '/users/verify-email';
  static const String deactivateUser = '/users/deactivate';

  // Feed endpoints
  static const String feed = '/feed';
  static const String feedInteractions = '/feed/interactions';
  static const String refreshFeed = '/feed/refresh';

  // Post endpoints
  static const String posts = '/posts';
  static const String userPosts = '/posts/user/{id}';
  static const String feedPosts = '/posts/feed';
  static const String likePost = '/posts/{id}/like';
  static const String bookmarkPost = '/posts/{id}/bookmark';
  static const String sharePost = '/posts/{id}/share';
  static const String reportPost = '/posts/{id}/report';
  static const String postLikes = '/posts/{id}/likes';
  static const String postStats = '/posts/{id}/stats';
  static const String searchPosts = '/posts/search';
  static const String trendingPosts = '/posts/trending';

  // Comment endpoints
  static const String comments = '/comments';
  static const String postComments = '/posts/{id}/comments';
  static const String commentReplies = '/comments/{id}/replies';
  static const String likeComment = '/comments/{id}/like';
  static const String reportComment = '/comments/{id}/report';
  static const String pinComment = '/comments/{id}/pin';
  static const String userComments = '/users/{id}/comments';
  static const String commentThread = '/comments/{id}/thread';
  static const String voteComment = '/comments/{id}/vote';

  // Follow endpoints
  static const String followUser = '/users/{id}/follow';
  static const String followers = '/users/{id}/followers';
  static const String following = '/users/{id}/following';
  static const String pendingFollowRequests = '/follow-requests/pending';
  static const String sentFollowRequests = '/follow-requests/sent';
  static const String acceptFollowRequest = '/follow-requests/{id}/accept';
  static const String rejectFollowRequest = '/follow-requests/{id}/reject';
  static const String cancelFollowRequest = '/follow-requests/{id}/cancel';
  static const String removeFollower = '/followers/{id}/remove';
  static const String followStats = '/users/{id}/follow-stats';
  static const String followStatus = '/users/{id}/follow-status';
  static const String mutualFollows = '/users/{id}/mutual-follows';
  static const String bulkFollow = '/follow/bulk';
  static const String followActivity = '/follow-activity';

  // Message endpoints
  static const String messages = '/messages';
  static const String conversationMessages = '/conversations/{id}/messages';
  static const String markMessagesRead = '/conversations/{id}/mark-read';
  static const String searchMessages = '/messages/search';
  static const String reactToMessage = '/messages/{id}/react';
  static const String messageStats = '/messages/stats';

  // Conversation endpoints
  static const String conversations = '/conversations';
  static const String conversationsWithTotal = '/conversations/with-total';
  static const String addParticipants = '/conversations/{id}/participants';
  static const String removeParticipant =
      '/conversations/{id}/participants/{participantId}';
  static const String leaveConversation = '/conversations/{id}/leave';
  static const String updateParticipantRole =
      '/conversations/{id}/participants/{participantId}';
  static const String archiveConversation = '/conversations/{id}/archive';
  static const String muteConversation = '/conversations/{id}/mute';
  static const String conversationStats = '/conversations/{id}/stats';
  static const String unreadCounts = '/conversations/unread-counts';
  static const String searchConversations = '/conversations/search';

  // Group endpoints
  static const String groups = '/groups';
  static const String groupBySlug = '/groups/slug/{slug}';
  static const String joinGroup = '/groups/{id}/join';
  static const String leaveGroup = '/groups/{id}/leave';
  static const String inviteToGroup = '/groups/{id}/invite';
  static const String acceptGroupInvite = '/group-invites/{id}/accept';
  static const String rejectGroupInvite = '/group-invites/{id}/reject';
  static const String groupMembers = '/groups/{id}/members';
  static const String userGroups = '/users/{id}/groups';
  static const String searchGroups = '/groups/search';
  static const String updateMemberRole = '/groups/{id}/members/{memberId}/role';
  static const String removeGroupMember = '/groups/{id}/members/{memberId}';
  static const String groupStats = '/groups/{id}/stats';
  static const String publicGroups = '/groups/public';
  static const String trendingGroups = '/groups/trending';

  // Like endpoints
  static const String likes = '/likes';
  static const String targetLikes = '/likes/target/{type}/{id}';
  static const String reactionSummary = '/likes/target/{type}/{id}/summary';
  static const String detailedReactionStats =
      '/likes/target/{type}/{id}/detailed-stats';
  static const String checkUserReaction = '/likes/check/{type}/{id}';
  static const String userLikes = '/likes/user/{id}';
  static const String trendingReactions = '/likes/trending';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String bulkNotifications = '/notifications/bulk';
  static const String markNotificationsRead = '/notifications/mark-read';
  static const String markAllNotificationsRead = '/notifications/mark-all-read';
  static const String notificationStats = '/notifications/stats';
  static const String notificationPreferences = '/notifications/preferences';

  // Media endpoints
  static const String mediaUpload = '/media/upload';
  static const String media = '/media';
  static const String userMedia = '/media/user/{id}';
  static const String searchMedia = '/media/search';
  static const String mediaStats = '/media/stats';
  static const String downloadMedia = '/media/{id}/download';
  static const String mediaUrl = '/media/{id}/url';

  // Search endpoints
  static const String search = '/search';
  static const String searchUsers = '/search/users';
  static const String searchHashtags = '/search/hashtags';
  static const String trendingHashtags = '/search/hashtags/trending';
  static const String searchSuggestions = '/search/suggestions';

  // Story endpoints
  static const String stories = '/stories';
  static const String userStories = '/stories/user/{id}';
  static const String followingStories = '/stories/following';
  static const String viewStory = '/stories/{id}/view';
  static const String storyViews = '/stories/{id}/views';
  static const String reactToStory = '/stories/{id}/react';
  static const String storyReactions = '/stories/{id}/reactions';
  static const String storyStats = '/stories/{id}/stats';
  static const String activeStories = '/stories/active';
  static const String archiveStory = '/stories/{id}/archive';
  static const String archivedStories = '/stories/archived';
  static const String storyHighlights = '/story-highlights';
  static const String userStoryHighlights = '/story-highlights/user/{id}';

  // Push notification endpoints
  static const String registerPushToken = '/push/register';
  static const String removePushToken = '/push/token';
  static const String userPushTokens = '/push/tokens';
  static const String testNotification = '/push/test';

  // Analytics endpoints
  static const String analyticsEvents = '/analytics/events';
  static const String analyticsPageViews = '/analytics/page-views';
  static const String analyticsUserActions = '/analytics/user-actions';
  static const String analyticsPostViews = '/analytics/post-views';
  static const String userAnalytics = '/analytics/users/{id}';
  static const String postAnalytics = '/analytics/posts/{id}';
  static const String userEngagement = '/analytics/users/{id}/engagement';

  // Report endpoints
  static const String reports = '/reports';
  static const String userReports = '/reports/user/{id}';

  // Behavior tracking endpoints
  static const String startSession = '/behavior/sessions/start';
  static const String endSession = '/behavior/sessions/end';
  static const String pageVisit = '/behavior/page-visit';
  static const String userAction = '/behavior/action';
  static const String contentEngagement = '/behavior/engagement';
  static const String postInteraction = '/behavior/post-interaction';
  static const String storyView = '/behavior/story-view';
  static const String searchBehavior = '/behavior/search';
  static const String interaction = '/behavior/interaction';
  static const String recommendation = '/behavior/recommendation';
  static const String experiment = '/behavior/experiment';
  static const String behaviorAnalytics = '/behavior/analytics';
  static const String interestScore = '/behavior/interest-score/{id}';
  static const String contentPreferences = '/behavior/preferences';
  static const String similarUsers = '/behavior/similar-users';

  // Helper methods for URL building
  static String buildUrl(String endpoint, {Map<String, String>? pathParams}) {
    String url = endpoint;

    if (pathParams != null) {
      pathParams.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }

    return url;
  }

  // Common path parameter replacements
  static String replaceUserId(String endpoint, String userId) {
    return endpoint.replaceAll('{id}', userId);
  }

  static String replacePostId(String endpoint, String postId) {
    return endpoint.replaceAll('{id}', postId);
  }

  static String replaceCommentId(String endpoint, String commentId) {
    return endpoint.replaceAll('{id}', commentId);
  }

  static String replaceGroupId(String endpoint, String groupId) {
    return endpoint.replaceAll('{id}', groupId);
  }

  static String replaceConversationId(String endpoint, String conversationId) {
    return endpoint.replaceAll('{id}', conversationId);
  }

  static String replaceStoryId(String endpoint, String storyId) {
    return endpoint.replaceAll('{id}', storyId);
  }

  static String replaceMediaId(String endpoint, String mediaId) {
    return endpoint.replaceAll('{id}', mediaId);
  }

  static String replaceReportId(String endpoint, String reportId) {
    return endpoint.replaceAll('{id}', reportId);
  }

  // Build URL with multiple path parameters
  static String buildUrlWithParams(
      String endpoint, Map<String, String> params) {
    String url = endpoint;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return url;
  }
}
