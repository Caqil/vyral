import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetFollowingUseCase {
  final ProfileRepository repository;

  GetFollowingUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call(
      GetFollowingParams params) async {
    return await repository.getFollowing(
      params.userId,
      params.page,
      params.limit,
    );
  }
}

class GetFollowingParams {
  final String userId;
  final int page;
  final int limit;

  GetFollowingParams({
    required this.userId,
    required this.page,
    required this.limit,
  });
}
