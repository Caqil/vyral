import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';

class BookmarkPostUseCase {
  final PostsRepository repository;

  BookmarkPostUseCase(this.repository);

  Future<Either<Failure, bool>> call(String postId) async {
    return await repository.bookmarkPost(postId);
  }
}
