import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';

class DeleteCommentUseCase {
  final PostsRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<Either<Failure, void>> call(String commentId) async {
    return await repository.deleteComment(commentId);
  }
}
