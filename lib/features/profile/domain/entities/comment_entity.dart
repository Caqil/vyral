// lib/features/profile/domain/entities/comment_entity.dart
import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
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

  const CommentEntity({
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

  @override
  List<Object?> get props => [
        id,
        postId,
        authorId,
        parentCommentId,
        content,
        contentType,
        mentions,
        likesCount,
        repliesCount,
        isLiked,
        isPinned,
        createdAt,
        updatedAt,
      ];

  bool get isReply => parentCommentId != null;
  bool get hasReplies => repliesCount > 0;

  CommentEntity copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? parentCommentId,
    String? content,
    String? contentType,
    List<String>? mentions,
    int? likesCount,
    int? repliesCount,
    bool? isLiked,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      mentions: mentions ?? this.mentions,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isLiked: isLiked ?? this.isLiked,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
