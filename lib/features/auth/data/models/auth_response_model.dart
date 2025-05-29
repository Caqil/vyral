// lib/features/auth/data/models/auth_response_model.dart
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
      // The JSON structure is: { "tokens": {...}, "user": {...} }
      // This is the extracted 'data' portion from the API response

      if (!json.containsKey('tokens') || !json.containsKey('user')) {
        throw Exception('Missing tokens or user in response');
      }

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
    } catch (e, stackTrace) {
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
