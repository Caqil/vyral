import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class BlockUserUseCase {
  final ProfileRepository repository;

  BlockUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    // This would be implemented in a separate service/repository
    // For now, we'll assume it's part of the profile repository
    throw UnimplementedError('Block user functionality not implemented');
  }
}
