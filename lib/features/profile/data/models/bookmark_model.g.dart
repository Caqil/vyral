// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookmarkModel _$BookmarkModelFromJson(Map<String, dynamic> json) =>
    BookmarkModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      postId: json['postId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BookmarkModelToJson(BookmarkModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'postId': instance.postId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
