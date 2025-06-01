// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_highlight_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryHighlightModel _$StoryHighlightModelFromJson(Map<String, dynamic> json) =>
    StoryHighlightModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      storyIds:
          (json['storyIds'] as List<dynamic>).map((e) => e as String).toList(),
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StoryHighlightModelToJson(
        StoryHighlightModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'coverImageUrl': instance.coverImageUrl,
      'storyIds': instance.storyIds,
      'viewsCount': instance.viewsCount,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
