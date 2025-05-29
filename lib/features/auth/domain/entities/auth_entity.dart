import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class AuthEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;
  final DateTime expiresAt;
  final String tokenType;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        user,
        expiresAt,
        tokenType,
      ];

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
