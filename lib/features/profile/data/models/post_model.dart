import 'package:json_annotation/json_annotation.dart';
import 'package:vyral/features/profile/domain/entities/post_entity.dart';
part 'post_model.g.dart';

@JsonSerializable()
class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.content,
    required super.contentType,
    required super.type,
    required super.visibility,
    super.mediaUrls,
    super.hashtags,
    super.mentions,
    super.location,
    super.likesCount,
    super.commentsCount,
    super.sharesCount,
    super.viewsCount,
    super.isLiked,
    super.isBookmarked,
    super.commentsEnabled,
    super.likesEnabled,
    super.sharesEnabled,
    super.isPinned,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      contentType: json['content_type'] as String,
      type: json['type'] as String,
      visibility: json['visibility'] as String,
      mediaUrls: json['media_urls'] != null
          ? List<String>.from(json['media_urls'] as List)
          : [],
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'] as List)
          : [],
      mentions: json['mentions'] != null
          ? List<String>.from(json['mentions'] as List)
          : [],
      location: json['location'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      commentsEnabled: json['comments_enabled'] as bool? ?? true,
      likesEnabled: json['likes_enabled'] as bool? ?? true,
      sharesEnabled: json['shares_enabled'] as bool? ?? true,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}
