import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserByUsernameUseCase {
  final ProfileRepository repository;

  GetUserByUsernameUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String username) async {
    return await repository.getUserByUsername(username);
  }
}
