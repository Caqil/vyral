import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
import '../entities/comment_with_author_entity.dart';

class CreateCommentUseCase {
  final PostsRepository repository;

  CreateCommentUseCase(this.repository);

  Future<Either<Failure, CommentWithAuthorEntity>> call(
    CreateCommentParams params,
  ) async {
    return await repository.createComment(
      params.postId,
      params.content,
      params.parentCommentId,
      params.mentions,
    );
  }
}

class CreateCommentParams {
  final String postId;
  final String content;
  final String? parentCommentId;
  final List<String> mentions;

  CreateCommentParams({
    required this.postId,
    required this.content,
    this.parentCommentId,
    this.mentions = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'post_id': postId,
      'content': content,
      'content_type': 'text',
      'mentions': mentions,
    };

    if (parentCommentId != null) {
      data['parent_comment_id'] = parentCommentId;
    }

    return data;
  }
}
