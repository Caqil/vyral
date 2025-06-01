import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/media_entity.dart';
import '../repositories/profile_repository.dart';
class GetUserMediaUseCase {
  final ProfileRepository repository;

  GetUserMediaUseCase(this.repository);

  Future<Either<Failure, List<MediaEntity>>> call(
      GetUserMediaParams params) async {
    return await repository.getUserMedia(
      params.userId,
      params.page,
      params.limit,
      type: params.type,
    );
  }
}

class GetUserMediaParams {
  final String userId;
  final int page;
  final int limit;
  final String? type;

  GetUserMediaParams({
    required this.userId,
    required this.page,
    required this.limit,
    this.type,
  });
}
