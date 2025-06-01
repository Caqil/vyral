import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/user_stats_entity.dart';
import '../repositories/profile_repository.dart';
class GetUserStatsUseCase {
  final ProfileRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<Either<Failure, UserStatsEntity>> call(String userId) async {
    return await repository.getUserStats(userId);
  }
}
