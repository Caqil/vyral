import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String id;
  final String userId;
  final String deviceInfo;
  final String? ipAddress;
  final String? userAgent;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final DateTime? expiresAt;

  const SessionEntity({
    required this.id,
    required this.userId,
    required this.deviceInfo,
    this.ipAddress,
    this.userAgent,
    required this.isActive,
    required this.createdAt,
    required this.lastUsedAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        deviceInfo,
        ipAddress,
        userAgent,
        isActive,
        createdAt,
        lastUsedAt,
        expiresAt,
      ];

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
