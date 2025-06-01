import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';
class GetFollowersUseCase {
  final ProfileRepository repository;

  GetFollowersUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call(
      GetFollowersParams params) async {
    return await repository.getFollowers(
      params.userId,
      params.page,
      params.limit,
    );
  }
}

class GetFollowersParams {
  final String userId;
  final int page;
  final int limit;

  GetFollowersParams({
    required this.userId,
    required this.page,
    required this.limit,
  });
}
