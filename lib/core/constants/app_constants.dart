class AppConstants {
  // App info
  static const String appName = 'Social Network';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 500;
  static const int maxPostLength = 2000;
  static const int maxCommentLength = 1000;

  // File upload
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];

  // Cache durations
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(hours: 1);
  static const Duration cacheLongDuration = Duration(days: 1);

  // Animation durations
  static const Duration shortAnimDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimDuration = Duration(milliseconds: 300);
  static const Duration longAnimDuration = Duration(milliseconds: 500);

  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';

  // Error messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String sessionExpiredMessage =
      'Session expired. Please login again.';
}
