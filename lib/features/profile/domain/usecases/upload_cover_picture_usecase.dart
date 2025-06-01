import 'package:dartz/dartz.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UploadCoverPictureUseCase {
  final ProfileRepository repository;

  UploadCoverPictureUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String filePath) async {
    // This would typically involve uploading to media service first
    // then updating the profile with the new image URL
    final data = {
      'cover_picture': filePath, // This would be the uploaded URL
    };
    return await repository.updateProfile(data);
  }
}
