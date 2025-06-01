// lib/features/profile/presentation/bloc/edit_profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
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

  EditProfileBloc({
    required this.getUserProfile,
    required this.updateProfile,
    required this.uploadProfilePicture,
    required this.uploadCoverPicture,
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
    emit(state.copyWith(isLoading: true));

    // Get current user ID from auth service
    const currentUserId = 'current_user_id'; // This should come from auth state

    final result = await getUserProfile(currentUserId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        ));
      },
      (user) {
        emit(state.copyWith(
          isLoading: false,
          user: user,
          hasError: false,
          errorMessage: null,
        ));
      },
    );
  }

  void _onInitialized(
    EditProfileInitialized event,
    Emitter<edit.EditProfileState> emit,
  ) {
    emit(state.copyWith(isInitialized: true));
  }

  Future<void> _onSaveRequested(
    EditProfileSaveRequested event,
    Emitter<edit.EditProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    final params = UpdateProfileParams(
      firstName: event.firstName?.isNotEmpty == true ? event.firstName : null,
      lastName: event.lastName?.isNotEmpty == true ? event.lastName : null,
      displayName:
          event.displayName?.isNotEmpty == true ? event.displayName : null,
      bio: event.bio?.isNotEmpty == true ? event.bio : null,
      website: event.website?.isNotEmpty == true ? event.website : null,
      location: event.location?.isNotEmpty == true ? event.location : null,
      phone: event.phone?.isNotEmpty == true ? event.phone : null,
      dateOfBirth: event.dateOfBirth,
      gender: event.gender,
      socialLinks: event.socialLinks,
      isPrivate: event.isPrivate,
    );

    final result = await updateProfile(params);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        ));
      },
      (updatedUser) {
        emit(state.copyWith(
          isLoading: false,
          user: updatedUser,
          isSuccess: true,
          hasError: false,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onProfilePictureChanged(
    EditProfileProfilePictureChanged event,
    Emitter<edit.EditProfileState> emit,
  ) async {
    if (event.imagePath == null) {
      // Remove profile picture
      final params = UpdateProfileParams(profilePicture: null);
      final result = await updateProfile(params);

      result.fold(
        (failure) {
          emit(state.copyWith(
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) {
          emit(state.copyWith(
            user: updatedUser,
            isSuccess: true,
          ));
        },
      );
    } else {
      // Upload new profile picture
      emit(state.copyWith(isUploadingProfilePicture: true));

      final result = await uploadProfilePicture(event.imagePath!);

      result.fold(
        (failure) {
          emit(state.copyWith(
            isUploadingProfilePicture: false,
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) {
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
    if (event.imagePath == null) {
      // Remove cover picture
      final params = UpdateProfileParams(coverPicture: null);
      final result = await updateProfile(params);

      result.fold(
        (failure) {
          emit(state.copyWith(
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) {
          emit(state.copyWith(
            user: updatedUser,
            isSuccess: true,
          ));
        },
      );
    } else {
      // Upload new cover picture
      emit(state.copyWith(isUploadingCoverPicture: true));

      final result = await uploadCoverPicture(event.imagePath!);

      result.fold(
        (failure) {
          emit(state.copyWith(
            isUploadingCoverPicture: false,
            hasError: true,
            errorMessage: failure.message,
          ));
        },
        (updatedUser) {
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
    emit(state.copyWith(isLoading: true));

    // This would typically call a deactivate account use case
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      emit(state.copyWith(
        isLoading: false,
        isDeactivated: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to deactivate account: $e',
      ));
    }
  }
}
