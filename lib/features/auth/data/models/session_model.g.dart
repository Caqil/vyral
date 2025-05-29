// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deviceInfo: json['device_info'] as String,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUsedAt: DateTime.parse(json['last_used_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'device_info': instance.deviceInfo,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'last_used_at': instance.lastUsedAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
    };
