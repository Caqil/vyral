// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareModel _$ShareModelFromJson(Map<String, dynamic> json) => ShareModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      postId: json['postId'] as String,
      shareType: json['shareType'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ShareModelToJson(ShareModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'postId': instance.postId,
      'shareType': instance.shareType,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
    };
