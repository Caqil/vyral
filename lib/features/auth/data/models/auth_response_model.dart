import 'package:json_annotation/json_annotation.dart';
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
      // Handle different possible response formats
      final accessToken = json['access_token']?.toString() ??
          json['accessToken']?.toString() ??
          json['token']?.toString();

      final refreshToken =
          json['refresh_token']?.toString() ?? json['refreshToken']?.toString();

      if (accessToken == null || refreshToken == null) {
        throw Exception('Missing required tokens in response');
      }

      // Parse user data
      final userData = json['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw Exception('Missing user data in response');
      }

      // Parse expiration date
      DateTime expiresAt;
      if (json['expires_at'] != null) {
        expiresAt = DateTime.parse(json['expires_at'].toString());
      } else if (json['expiresAt'] != null) {
        expiresAt = DateTime.parse(json['expiresAt'].toString());
      } else {
        // Default to 1 hour from now if not provided
        expiresAt = DateTime.now().add(const Duration(hours: 1));
      }

      return AuthResponseModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: UserModel.fromJson(userData),
        expiresAt: expiresAt,
        tokenType: json['token_type']?.toString() ??
            json['tokenType']?.toString() ??
            'Bearer',
      );
    } catch (e) {
      throw Exception('Failed to parse auth response: $e');
    }
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
}
