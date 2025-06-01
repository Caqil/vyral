import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/follow_status_entity.dart';
import '../repositories/profile_repository.dart';
class UnfollowUserUseCase {
  final ProfileRepository repository;

  UnfollowUserUseCase(this.repository);

  Future<Either<Failure, FollowStatusEntity>> call(String userId) async {
    return await repository.unfollowUser(userId);
  }
}
