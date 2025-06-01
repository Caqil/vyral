import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/follow_status_entity.dart';
import '../repositories/profile_repository.dart';
class FollowUserUseCase {
  final ProfileRepository repository;

  FollowUserUseCase(this.repository);

  Future<Either<Failure, FollowStatusEntity>> call(String userId) async {
    return await repository.followUser(userId);
  }
}
