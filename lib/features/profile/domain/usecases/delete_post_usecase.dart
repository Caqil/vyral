import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';

class DeletePostUseCase {
  final PostsRepository repository;

  DeletePostUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId) async {
    return await repository.deletePost(postId);
  }
}
