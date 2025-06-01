// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikeModel _$LikeModelFromJson(Map<String, dynamic> json) => LikeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      reactionType: json['reactionType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LikeModelToJson(LikeModel instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'targetId': instance.targetId,
      'targetType': instance.targetType,
      'reactionType': instance.reactionType,
      'createdAt': instance.createdAt.toIso8601String(),
    };
