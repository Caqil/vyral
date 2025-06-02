abstract class EditProfileEvent {
  const EditProfileEvent();
}

class EditProfileLoadRequested extends EditProfileEvent {
  const EditProfileLoadRequested();
}

class EditProfileInitialized extends EditProfileEvent {
  const EditProfileInitialized();
}

class EditProfileSaveRequested extends EditProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? bio;
  final String? website;
  final String? location;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final Map<String, String>? socialLinks;
  final bool? isPrivate;

  const EditProfileSaveRequested({
    this.firstName,
    this.lastName,
    this.displayName,
    this.bio,
    this.website,
    this.location,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.socialLinks,
    this.isPrivate,
  });
}

class EditProfileProfilePictureChanged extends EditProfileEvent {
  final String? imagePath;

  const EditProfileProfilePictureChanged({this.imagePath});
}

class EditProfileCoverPictureChanged extends EditProfileEvent {
  final String? imagePath;

  const EditProfileCoverPictureChanged({this.imagePath});
}

class EditProfileDeactivateRequested extends EditProfileEvent {
  const EditProfileDeactivateRequested();
}
