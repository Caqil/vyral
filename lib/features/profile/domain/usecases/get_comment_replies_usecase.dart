import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
import '../entities/comment_with_author_entity.dart';

class GetCommentRepliesUseCase {
  final PostsRepository repository;

  GetCommentRepliesUseCase(this.repository);

  Future<Either<Failure, List<CommentWithAuthorEntity>>> call(
    GetCommentRepliesParams params,
  ) async {
    return await repository.getCommentReplies(
      params.commentId,
      params.page,
      params.limit,
    );
  }
}

class GetCommentRepliesParams {
  final String commentId;
  final int page;
  final int limit;

  GetCommentRepliesParams({
    required this.commentId,
    this.page = 0,
    this.limit = 20,
  });
}
