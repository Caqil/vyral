import 'package:vyral/features/profile/domain/entities/user_entity.dart';

class EditProfileState {
  final UserEntity? user;
  final bool isLoading;
  final bool isUploadingProfilePicture;
  final bool isUploadingCoverPicture;
  final bool isInitialized;
  final bool isSuccess;
  final bool hasError;
  final String? errorMessage;
  final bool isDeactivated;

  const EditProfileState({
    this.user,
    this.isLoading = false,
    this.isUploadingProfilePicture = false,
    this.isUploadingCoverPicture = false,
    this.isInitialized = false,
    this.isSuccess = false,
    this.hasError = false,
    this.errorMessage,
    this.isDeactivated = false,
  });

  EditProfileState copyWith({
    UserEntity? user,
    bool? isLoading,
    bool? isUploadingProfilePicture,
    bool? isUploadingCoverPicture,
    bool? isInitialized,
    bool? isSuccess,
    bool? hasError,
    String? errorMessage,
    bool? isDeactivated,
  }) {
    return EditProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isUploadingProfilePicture:
          isUploadingProfilePicture ?? this.isUploadingProfilePicture,
      isUploadingCoverPicture:
          isUploadingCoverPicture ?? this.isUploadingCoverPicture,
      isInitialized: isInitialized ?? this.isInitialized,
      isSuccess: isSuccess ?? false, // Always reset success state
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      isDeactivated: isDeactivated ?? this.isDeactivated,
    );
  }
}

// Update the UpdateProfileParams to include profile and cover pictures
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

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (displayName != null) data['display_name'] = displayName;
    if (bio != null) data['bio'] = bio;
    if (website != null) data['website'] = website;
    if (location != null) data['location'] = location;
    if (dateOfBirth != null) {
      data['date_of_birth'] = dateOfBirth!.toIso8601String();
    }
    if (gender != null) data['gender'] = gender;
    if (phone != null) data['phone'] = phone;
    if (profilePicture != null) data['profile_picture'] = profilePicture;
    if (coverPicture != null) data['cover_picture'] = coverPicture;
    if (socialLinks != null) data['social_links'] = socialLinks;
    if (isPrivate != null) data['is_private'] = isPrivate;

    return data;
  }
}
