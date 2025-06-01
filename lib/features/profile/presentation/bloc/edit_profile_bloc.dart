import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/core/utils/logger.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_cover_picture_usecase.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart' as edit;

class EditProfileBloc extends Bloc<EditProfileEvent, edit.EditProfileState> {
  final GetUserProfileUseCase getUserProfile;
  final UpdateProfileUseCase updateProfile;
  final UploadProfilePictureUseCase uploadProfilePicture;
  final UploadCoverPictureUseCase uploadCoverPicture;
  final String? Function() getCurrentUserId;

  EditProfileBloc({
    required this.getUserProfile,
    required this.updateProfile,
    required this.uploadProfilePicture,
    required this.uploadCoverPicture,
    required this.getCurrentUserId,
  }) : super(const edit.EditProfileState()) {
    on<EditProfileLoadRequested>(_onLoadRequested);
    on<EditProfileInitialized>(_onInitialized);
    on<EditProfileSaveRequested>(_onSaveRequested);
    on<EditProfileProfilePictureChanged>(_onProfilePictureChanged);
    on<EditProfileCoverPictureChanged>(_onCoverPictureChanged);
    on<EditProfileDeactivateRequested>(_onDeactivateRequested);
  }

  Future<void> _onLoadRequested(
    EditProfileLoadRequested event,
    Emitter<edit.EditProfileState> emit,
  ) async {
    AppLogger.debug('🔄 EditProfileBloc: Loading profile...');
    emit(state.copyWith(isLoading: true, hasError: false, errorMessage: null));

    try {
      // Get the current user ID
      final currentUserId = getCurrentUserId();
      AppLogger.debug('🔍 EditProfileBloc: Current user ID: $currentUserId');

      if (currentUserId == null) {
        emit(state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'User not authenticated. Please log in again.',
        ));
        return;
      }

      // For edit profile, we use "current" as a special keyword
      // that the repository recognizes to get the current user's profile
      final result = await getUserProfile('current');

      result.fold(
        (failure) {
          AppLogger.debug(
              '❌ EditProfileBloc: Failed to load profile: ${failure.message}');
          emit(state.copyWith(
            isLoading: false,
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (user) {
          AppLogger.debug(
              '✅ EditProfileBloc: Profile loaded successfully for user: ${user.username}');
          emit(state.copyWith(
            isLoading: false,
            user: user,
            hasError: false,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      AppLogger.debug('❌ EditProfileBloc: Exception while loading profile: $e');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to load profile: $e',
      ));
    }
  }

  void _onInitialized(
    EditProfileInitialized event,
    Emitter<edit.EditProfileState> emit,
  ) {
    AppLogger.debug('🔄 EditProfileBloc: Profile initialized');
    emit(state.copyWith(isInitialized: true));
  }

  Future<void> _onSaveRequested(
    EditProfileSaveRequested event,
    Emitter<edit.EditProfileState> emit,
  ) async {
    AppLogger.debug('🔄 EditProfileBloc: Saving profile...');
    emit(state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
      isSuccess: false,
    ));

    try {
      // Create params with only the changed fields
      final params = UpdateProfileParams.onlyChanged(
        firstName: event.firstName?.isNotEmpty == true ? event.firstName : null,
        lastName: event.lastName?.isNotEmpty == true ? event.lastName : null,
        displayName:
            event.displayName?.isNotEmpty == true ? event.displayName : null,
        bio: event.bio, // Allow empty bio to clear it
        website: event.website, // Allow empty website to clear it
        location: event.location, // Allow empty location to clear it
        phone: event.phone, // Allow empty phone to clear it
        dateOfBirth: event.dateOfBirth,
        gender: event.gender,
        socialLinks: event.socialLinks,
        isPrivate: event.isPrivate,
      );

      AppLogger.debug(
          '🔄 EditProfileBloc: Updating profile with params: $params');

      final result = await updateProfile(params);

      result.fold(
        (failure) {
          AppLogger.debug(
              '❌ EditProfileBloc: Failed to update profile: ${failure.message}');
          emit(state.copyWith(
            isLoading: false,
            hasError: true,
            errorMessage: failure.message,
            isSuccess: false,
          ));
        },
        (updatedUser) {
          AppLogger.debug('✅ EditProfileBloc: Profile updated successfully');
          emit(state.copyWith(
            isLoading: false,
            user: updatedUser,
            isSuccess: true,
            hasError: false,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      AppLogger.debug(
          '❌ EditProfileBloc: Exception while updating profile: $e');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to update profile: $e',
        isSuccess: false,
      ));
    }
  }

  Future<void> _onProfilePictureChanged(
    EditProfileProfilePictureChanged event,
    Emitter<edit.EditProfileState> emit,
  ) async {
    AppLogger.debug('🔄 EditProfileBloc: Changing profile picture...');

    if (event.imagePath == null) {
      // Remove profile picture
      AppLogger.debug('🔄 EditProfileBloc: Removing profile picture');
      final params = UpdateProfileParams.onlyChanged(profilePicture: '');
      final result = await updateProfile(params);

      result.fold(
        (failure) {
          AppLogger.debug(
              '❌ EditProfileBloc: Failed to remove profile picture: ${failure.message}');
          emit(state.copyWith(
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) {
          AppLogger.debug(
              '✅ EditProfileBloc: Profile picture removed successfully');
          emit(state.copyWith(
            user: updatedUser,
            isSuccess: true,
          ));
        },
      );
    } else {
      // Upload new profile picture
      AppLogger.debug('🔄 EditProfileBloc: Uploading new profile picture');
      emit(state.copyWith(isUploadingProfilePicture: true));

      final result = await uploadProfilePicture(event.imagePath!);

      result.fold(
        (failure) {
          AppLogger.debug(
              '❌ EditProfileBloc: Failed to upload profile picture: ${failure.message}');
          emit(state.copyWith(
            isUploadingProfilePicture: false,
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) {
          AppLogger.debug(
              '✅ EditProfileBloc: Profile picture uploaded successfully');
          emit(state.copyWith(
            isUploadingProfilePicture: false,
            user: updatedUser,
            isSuccess: true,
          ));
        },
      );
    }
  }

  Future<void> _onCoverPictureChanged(
    EditProfileCoverPictureChanged event,
    Emitter<edit.EditProfileState> emit,
  ) async {
    AppLogger.debug('🔄 EditProfileBloc: Changing cover picture...');

    if (event.imagePath == null) {
      // Remove cover picture
      AppLogger.debug('🔄 EditProfileBloc: Removing cover picture');
      final params = UpdateProfileParams.onlyChanged(coverPicture: '');
      final result = await updateProfile(params);

      result.fold(
        (failure) {
          AppLogger.debug(
              '❌ EditProfileBloc: Failed to remove cover picture: ${failure.message}');
          emit(state.copyWith(
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) {
          AppLogger.debug(
              '✅ EditProfileBloc: Cover picture removed successfully');
          emit(state.copyWith(
            user: updatedUser,
            isSuccess: true,
          ));
        },
      );
    } else {
      // Upload new cover picture
      AppLogger.debug('🔄 EditProfileBloc: Uploading new cover picture');
      emit(state.copyWith(isUploadingCoverPicture: true));

      final result = await uploadCoverPicture(event.imagePath!);

      result.fold(
        (failure) {
          AppLogger.debug(
              '❌ EditProfileBloc: Failed to upload cover picture: ${failure.message}');
          emit(state.copyWith(
            isUploadingCoverPicture: false,
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) {
          AppLogger.debug(
              '✅ EditProfileBloc: Cover picture uploaded successfully');
          emit(state.copyWith(
            isUploadingCoverPicture: false,
            user: updatedUser,
            isSuccess: true,
          ));
        },
      );
    }
  }

  Future<void> _onDeactivateRequested(
    EditProfileDeactivateRequested event,
    Emitter<edit.EditProfileState> emit,
  ) async {
    AppLogger.debug('🔄 EditProfileBloc: Deactivating account...');
    emit(state.copyWith(isLoading: true));

    // This would typically call a deactivate account use case
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      AppLogger.debug('✅ EditProfileBloc: Account deactivated successfully');
      emit(state.copyWith(
        isLoading: false,
        isDeactivated: true,
      ));
    } catch (e) {
      AppLogger.debug('❌ EditProfileBloc: Failed to deactivate account: $e');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to deactivate account: $e',
      ));
    }
  }
}
