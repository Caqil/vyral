import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
import '../entities/like_entity.dart';

class LikeCommentUseCase {
  final PostsRepository repository;

  LikeCommentUseCase(this.repository);

  Future<Either<Failure, LikeEntity?>> call(LikeCommentParams params) async {
    return await repository.likeComment(
      params.commentId,
      params.reactionType,
    );
  }
}

class LikeCommentParams {
  final String commentId;
  final String reactionType;

  LikeCommentParams({
    required this.commentId,
    this.reactionType = 'like',
  });
}
