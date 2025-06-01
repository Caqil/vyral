import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
import '../entities/comment_with_author_entity.dart';

class GetPostCommentsUseCase {
  final PostsRepository repository;

  GetPostCommentsUseCase(this.repository);

  Future<Either<Failure, List<CommentWithAuthorEntity>>> call(
    GetPostCommentsParams params,
  ) async {
    return await repository.getPostComments(
      params.postId,
      params.page,
      params.limit,
      params.sortBy,
    );
  }
}

class GetPostCommentsParams {
  final String postId;
  final int page;
  final int limit;
  final String sortBy;

  GetPostCommentsParams({
    required this.postId,
    this.page = 0,
    this.limit = 20,
    this.sortBy = 'newest',
  });
}
