class StorageConstants {
  // Secure storage keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String fcmToken = 'fcm_token';
  static const String biometricEnabled = 'biometric_enabled';

  // Shared preferences keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String cacheVersion = 'cache_version';
  static const String lastSyncTime = 'last_sync_time';

  // Hive box names
  static const String userBox = 'user_box';
  static const String postsBox = 'posts_box';
  static const String conversationsBox = 'conversations_box';
  static const String cacheBox = 'cache_box';
  static const String settingsBox = 'settings_box';

  // Cache keys
  static const String userProfileCache = 'user_profile_cache_';
  static const String feedCache = 'feed_cache_';
  static const String conversationsCache = 'conversations_cache';
  static const String notificationsCache = 'notifications_cache';
  static const String suggestedUsersCache = 'suggested_users_cache';
}
