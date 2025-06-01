import 'package:json_annotation/json_annotation.dart';
part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String? parentCommentId;
  final String content;
  final String contentType;
  final List<String> mentions;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    this.parentCommentId,
    required this.content,
    required this.contentType,
    this.mentions = const [],
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
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
