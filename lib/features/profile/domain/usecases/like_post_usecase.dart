import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
import '../entities/like_entity.dart';

class LikePostUseCase {
  final PostsRepository repository;

  LikePostUseCase(this.repository);

  Future<Either<Failure, LikeEntity?>> call(LikePostParams params) async {
    return await repository.likePost(
      params.postId,
      params.reactionType,
    );
  }
}

class LikePostParams {
  final String postId;
  final String reactionType;

  LikePostParams({
    required this.postId,
    this.reactionType = 'heart',
  });
}
