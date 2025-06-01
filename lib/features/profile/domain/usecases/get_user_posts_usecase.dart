import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/post_entity.dart';
import '../repositories/profile_repository.dart';
class GetUserPostsUseCase {
  final ProfileRepository repository;

  GetUserPostsUseCase(this.repository);

  Future<Either<Failure, List<PostEntity>>> call(
      GetUserPostsParams params) async {
    return await repository.getUserPosts(
      params.userId,
      params.page,
      params.limit,
    );
  }
}

class GetUserPostsParams {
  final String userId;
  final int page;
  final int limit;

  GetUserPostsParams({
    required this.userId,
    required this.page,
    required this.limit,
  });
}
