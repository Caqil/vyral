// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowStatusModel _$FollowStatusModelFromJson(Map<String, dynamic> json) =>
    FollowStatusModel(
      userId: json['userId'] as String,
      targetUserId: json['targetUserId'] as String,
      isFollowing: json['isFollowing'] as bool,
      isFollowedBy: json['isFollowedBy'] as bool,
      isPending: json['isPending'] as bool,
      isBlocked: json['isBlocked'] as bool,
      isMuted: json['isMuted'] as bool,
      followedAt: json['followedAt'] == null
          ? null
          : DateTime.parse(json['followedAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FollowStatusModelToJson(FollowStatusModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'targetUserId': instance.targetUserId,
      'isFollowing': instance.isFollowing,
      'isFollowedBy': instance.isFollowedBy,
      'isPending': instance.isPending,
      'isBlocked': instance.isBlocked,
      'isMuted': instance.isMuted,
      'followedAt': instance.followedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
