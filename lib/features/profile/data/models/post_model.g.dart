// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      content: json['content'] as String,
      contentType: json['contentType'] as String,
      type: json['type'] as String,
      visibility: json['visibility'] as String,
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mentions: (json['mentions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      commentsEnabled: json['commentsEnabled'] as bool? ?? true,
      likesEnabled: json['likesEnabled'] as bool? ?? true,
      sharesEnabled: json['sharesEnabled'] as bool? ?? true,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'content': instance.content,
      'contentType': instance.contentType,
      'type': instance.type,
      'visibility': instance.visibility,
      'mediaUrls': instance.mediaUrls,
      'hashtags': instance.hashtags,
      'mentions': instance.mentions,
      'location': instance.location,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'sharesCount': instance.sharesCount,
      'viewsCount': instance.viewsCount,
      'isLiked': instance.isLiked,
      'isBookmarked': instance.isBookmarked,
      'commentsEnabled': instance.commentsEnabled,
      'likesEnabled': instance.likesEnabled,
      'sharesEnabled': instance.sharesEnabled,
      'isPinned': instance.isPinned,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
