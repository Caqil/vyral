import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/comment_entity.dart';
part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.authorId,
    super.parentCommentId,
    required super.content,
    required super.contentType,
    super.mentions = const [],
    super.likesCount = 0,
    super.repliesCount = 0,
    super.isLiked = false,
    super.isPinned = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String,
      contentType: json['content_type'] as String,
      mentions: json['mentions'] != null
          ? List<String>.from(json['mentions'] as List)
          : [],
      likesCount: json['likes_count'] as int? ?? 0,
      repliesCount: json['replies_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
