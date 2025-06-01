import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/story_highlight_entity.dart';
part 'story_highlight_model.g.dart';

@JsonSerializable()
class StoryHighlightModel extends StoryHighlightEntity {
  const StoryHighlightModel({
    required super.id,
    required super.userId,
    required super.title,
    super.coverImageUrl,
    required super.storyIds,
    super.viewsCount,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoryHighlightModel.fromJson(Map<String, dynamic> json) {
    return StoryHighlightModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      storyIds: json['story_ids'] != null
          ? List<String>.from(json['story_ids'] as List)
          : [],
      viewsCount: json['views_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$StoryHighlightModelToJson(this);
}
