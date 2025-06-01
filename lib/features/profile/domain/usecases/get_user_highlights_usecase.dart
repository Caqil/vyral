import 'package:dartz/dartz.dart';
import 'package:vyral/core/error/failures.dart';

import '../entities/story_highlight_entity.dart';
import '../repositories/profile_repository.dart';
class GetUserHighlightsUseCase {
  final ProfileRepository repository;

  GetUserHighlightsUseCase(this.repository);

  Future<Either<Failure, List<StoryHighlightEntity>>> call(
      String userId) async {
    return await repository.getUserHighlights(userId);
  }
}
