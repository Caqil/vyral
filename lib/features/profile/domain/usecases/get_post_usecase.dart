import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
import '../entities/post_entity.dart';

class GetPostUseCase {
  final PostsRepository repository;

  GetPostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(String postId) async {
    return await repository.getPost(postId);
  }
}
