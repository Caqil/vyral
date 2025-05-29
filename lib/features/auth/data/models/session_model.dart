import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/session_entity.dart';

part 'session_model.g.dart';

@JsonSerializable()
class SessionModel extends SessionEntity {
  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'device_info')
  final String deviceInfo;

  @JsonKey(name: 'ip_address')
  final String? ipAddress;

  @JsonKey(name: 'user_agent')
  final String? userAgent;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'last_used_at')
  final DateTime lastUsedAt;

  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  const SessionModel({
    required String id,
    required this.userId,
    required this.deviceInfo,
    this.ipAddress,
    this.userAgent,
    required this.isActive,
    required this.createdAt,
    required this.lastUsedAt,
    this.expiresAt,
  }) : super(
          id: id,
          userId: userId,
          deviceInfo: deviceInfo,
          ipAddress: ipAddress,
          userAgent: userAgent,
          isActive: isActive,
          createdAt: createdAt,
          lastUsedAt: lastUsedAt,
          expiresAt: expiresAt,
        );

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    try {
      return SessionModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
        deviceInfo: json['device_info']?.toString() ??
            json['deviceInfo']?.toString() ??
            'Unknown Device',
        ipAddress:
            json['ip_address']?.toString() ?? json['ipAddress']?.toString(),
        userAgent:
            json['user_agent']?.toString() ?? json['userAgent']?.toString(),
        isActive: json['is_active'] == true || json['isActive'] == true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : json['createdAt'] != null
                ? DateTime.parse(json['createdAt'].toString())
                : DateTime.now(),
        lastUsedAt: json['last_used_at'] != null
            ? DateTime.parse(json['last_used_at'].toString())
            : json['lastUsedAt'] != null
                ? DateTime.parse(json['lastUsedAt'].toString())
                : DateTime.now(),
        expiresAt: json['expires_at'] != null
            ? DateTime.tryParse(json['expires_at'].toString())
            : json['expiresAt'] != null
                ? DateTime.tryParse(json['expiresAt'].toString())
                : null,
      );
    } catch (e) {
      throw Exception('Failed to parse session data: $e');
    }
  }

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  factory SessionModel.fromEntity(SessionEntity entity) {
    return SessionModel(
      id: entity.id,
      userId: entity.userId,
      deviceInfo: entity.deviceInfo,
      ipAddress: entity.ipAddress,
      userAgent: entity.userAgent,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      lastUsedAt: entity.lastUsedAt,
      expiresAt: entity.expiresAt,
    );
  }
}
