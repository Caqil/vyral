import 'package:dartz/dartz.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.toJson());
  }
}

class UpdateProfileParams {
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? bio;
  final String? website;
  final String? location;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final Map<String, String>? socialLinks;
  final bool? isPrivate;

  UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.displayName,
    this.bio,
    this.website,
    this.location,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.socialLinks,
    this.isPrivate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (displayName != null) data['display_name'] = displayName;
    if (bio != null) data['bio'] = bio;
    if (website != null) data['website'] = website;
    if (location != null) data['location'] = location;
    if (dateOfBirth != null)
      data['date_of_birth'] = dateOfBirth!.toIso8601String();
    if (gender != null) data['gender'] = gender;
    if (phone != null) data['phone'] = phone;
    if (socialLinks != null) data['social_links'] = socialLinks;
    if (isPrivate != null) data['is_private'] = isPrivate;

    return data;
  }
}
