// lib/features/profile/domain/usecases/update_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    try {
      AppLogger.debug(
          '🔄 UpdateProfileUseCase called with params: ${params.toJson()}');
      return await repository.updateProfile(params.toJson());
    } catch (e) {
      AppLogger.debug('❌ UpdateProfileUseCase error: $e');
      rethrow;
    }
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
  final String? profilePicture;
  final String? coverPicture;
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
    this.profilePicture,
    this.coverPicture,
    this.socialLinks,
    this.isPrivate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Only add non-null and non-empty values to avoid sending unnecessary data
    if (firstName != null && firstName!.isNotEmpty) {
      data['first_name'] = firstName!.trim();
    }
    if (lastName != null && lastName!.isNotEmpty) {
      data['last_name'] = lastName!.trim();
    }
    if (displayName != null && displayName!.isNotEmpty) {
      data['display_name'] = displayName!.trim();
    }
    if (bio != null) {
      // Allow empty bio to clear it
      data['bio'] = bio!.trim();
    }
    if (website != null) {
      // Allow empty website to clear it
      data['website'] = website!.trim();
    }
    if (location != null) {
      // Allow empty location to clear it
      data['location'] = location!.trim();
    }
    if (dateOfBirth != null) {
      data['date_of_birth'] = dateOfBirth!.toIso8601String();
    }
    if (gender != null && gender!.isNotEmpty) {
      data['gender'] = gender!.trim();
    }
    if (phone != null) {
      // Allow empty phone to clear it
      data['phone'] = phone!.trim();
    }
    if (profilePicture != null) {
      data['profile_picture'] = profilePicture!.trim();
    }
    if (coverPicture != null) {
      data['cover_picture'] = coverPicture!.trim();
    }
    if (socialLinks != null) {
      // Filter out empty social links
      final filteredLinks = Map<String, String>.from(socialLinks!)
        ..removeWhere((key, value) => value.trim().isEmpty);
      if (filteredLinks.isNotEmpty) {
        data['social_links'] = filteredLinks;
      }
    }
    if (isPrivate != null) {
      data['is_private'] = isPrivate;
    }

    AppLogger.debug('📤 UpdateProfileParams.toJson(): $data');
    return data;
  }

  // Helper method to create params from current user data with updates
  factory UpdateProfileParams.fromUserWithUpdates(
    UserEntity currentUser, {
    String? firstName,
    String? lastName,
    String? displayName,
    String? bio,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? profilePicture,
    String? coverPicture,
    Map<String, String>? socialLinks,
    bool? isPrivate,
  }) {
    return UpdateProfileParams(
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      displayName: displayName ?? currentUser.displayName,
      bio: bio ?? currentUser.bio,
      website: website ?? currentUser.website,
      location: location ?? currentUser.location,
      dateOfBirth: dateOfBirth ?? currentUser.dateOfBirth,
      gender: gender ?? currentUser.gender,
      phone: phone ?? currentUser.phone,
      profilePicture: profilePicture ?? currentUser.profilePicture,
      coverPicture: coverPicture ?? currentUser.coverPicture,
      socialLinks: socialLinks ?? currentUser.socialLinks,
      isPrivate: isPrivate ?? currentUser.isPrivate,
    );
  }

  // Create params with only the fields that have been changed
  factory UpdateProfileParams.onlyChanged({
    String? firstName,
    String? lastName,
    String? displayName,
    String? bio,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? profilePicture,
    String? coverPicture,
    Map<String, String>? socialLinks,
    bool? isPrivate,
  }) {
    return UpdateProfileParams(
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
      bio: bio,
      website: website,
      location: location,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phone: phone,
      profilePicture: profilePicture,
      coverPicture: coverPicture,
      socialLinks: socialLinks,
      isPrivate: isPrivate,
    );
  }

  @override
  String toString() {
    return 'UpdateProfileParams(${toJson()})';
  }
}
