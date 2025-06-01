import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
import '../entities/comment_entity.dart';

class UpdateCommentUseCase {
  final PostsRepository repository;

  UpdateCommentUseCase(this.repository);

  Future<Either<Failure, CommentEntity>> call(
      UpdateCommentParams params) async {
    return await repository.updateComment(
      params.commentId,
      params.content,
    );
  }
}

class UpdateCommentParams {
  final String commentId;
  final String content;

  UpdateCommentParams({
    required this.commentId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}
