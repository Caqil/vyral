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
