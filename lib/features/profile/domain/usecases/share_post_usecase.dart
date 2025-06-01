import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';

class SharePostUseCase {
  final PostsRepository repository;

  SharePostUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId) async {
    return await repository.sharePost(postId);
  }
}
