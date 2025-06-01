import 'package:equatable/equatable.dart';
import 'package:vyral/features/profile/domain/entities/comment_entity.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';

class CommentWithAuthorEntity extends Equatable {
  final CommentEntity comment;
  final UserEntity author;
  final List<CommentWithAuthorEntity> replies;

  const CommentWithAuthorEntity({
    required this.comment,
    required this.author,
    this.replies = const [],
  });

  @override
  List<Object?> get props => [comment, author, replies];

  bool get hasReplies => replies.isNotEmpty;
}
