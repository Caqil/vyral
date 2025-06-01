import 'package:json_annotation/json_annotation.dart';
import 'package:vyral/core/utils/logger.dart';
import '../../domain/entities/auth_entity.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel extends AuthEntity {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  }) : super(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
          expiresAt: expiresAt,
          tokenType: tokenType,
        );

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle login response format: { "tokens": {...}, "user": {...} }
      if (json.containsKey('tokens') && json.containsKey('user')) {
        return _parseLoginResponse(json);
      }

      // Handle refresh response format: { "access_token": "...", "refresh_token": "...", ... }
      // This format is used when no user data is provided (refresh endpoint)
      if (json.containsKey('access_token') &&
          json.containsKey('refresh_token')) {
        return _parseRefreshResponse(json);
      }

      throw Exception('Invalid response format: missing required token fields');
    } catch (e, stackTrace) {
      AppLogger.debug('AuthResponseModel parsing error: $e');
      AppLogger.debug('StackTrace: $stackTrace');
      AppLogger.debug('JSON data: $json');
      throw Exception('Failed to parse auth response: $e');
    }
  }

  static AuthResponseModel _parseLoginResponse(Map<String, dynamic> json) {
    final tokensData = json['tokens'] as Map<String, dynamic>;
    final userData = json['user'] as Map<String, dynamic>;

    // Extract tokens
    final accessToken = tokensData['access_token']?.toString();
    final refreshToken = tokensData['refresh_token']?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing or empty access_token in response');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Missing or empty refresh_token in response');
    }

    // Calculate expiration date
    DateTime expiresAt;
    if (tokensData['expires_in'] != null) {
      final expiresIn = tokensData['expires_in'] as int; // in seconds
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    } else if (tokensData['expires_at'] != null) {
      expiresAt = DateTime.parse(tokensData['expires_at'].toString());
    } else {
      // Default to 1 hour from now
      expiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    return AuthResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: UserModel.fromJson(userData),
      expiresAt: expiresAt,
      tokenType: tokensData['token_type']?.toString() ?? 'Bearer',
    );
  }

  static AuthResponseModel _parseRefreshResponse(Map<String, dynamic> json) {
    // Extract tokens
    final accessToken = json['access_token']?.toString();
    final refreshToken = json['refresh_token']?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing or empty access_token in response');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Missing or empty refresh_token in response');
    }

    // Calculate expiration date
    DateTime expiresAt;
    if (json['expires_in'] != null) {
      final expiresIn = json['expires_in'] as int; // in seconds
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    } else if (json['expires_at'] != null) {
      expiresAt = DateTime.parse(json['expires_at'].toString());
    } else {
      // Default to 1 hour from now
      expiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    // Since refresh response doesn't include user data, we need to handle this
    // The user data should be preserved from the previous auth state
    // We'll create a minimal user model that will be updated later
    final userData =
        json['user'] as Map<String, dynamic>? ?? _createMinimalUserData();

    return AuthResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: UserModel.fromJson(userData),
      expiresAt: expiresAt,
      tokenType: json['token_type']?.toString() ?? 'Bearer',
    );
  }

  static Map<String, dynamic> _createMinimalUserData() {
    // Create minimal user data structure
    // This will be updated with actual user data from local storage
    return {
      'id': '',
      'username': '',
      'email': '',
      'first_name': null,
      'last_name': null,
      'display_name': null,
      'bio': null,
      'profile_pic': null,
      'cover_pic': null,
      'website': null,
      'location': null,
      'date_of_birth': null,
      'gender': null,
      'phone': null,
      'social_links': null,
      'is_verified': false,
      'is_private': false,
      'followers_count': 0,
      'following_count': 0,
      'posts_count': 0,
      'friends_count': 0,
      'is_premium': false,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  factory AuthResponseModel.fromEntity(AuthEntity entity) {
    return AuthResponseModel(
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      user: UserModel.fromEntity(entity.user),
      expiresAt: entity.expiresAt,
      tokenType: entity.tokenType,
    );
  }

  // Helper method to update user data
  AuthResponseModel copyWithUser(UserModel user) {
    return AuthResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
      expiresAt: expiresAt,
      tokenType: tokenType,
    );
  }
}
