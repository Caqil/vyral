

import 'package:vyral/features/profile/domain/entities/user_entity.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;

  const ProfileLoadRequested({required this.userId});
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

class ProfileFollowRequested extends ProfileEvent {
  final String userId;

  const ProfileFollowRequested({required this.userId});
}

class ProfileUnfollowRequested extends ProfileEvent {
  final String userId;

  const ProfileUnfollowRequested({required this.userId});
}

class ProfileLoadMorePostsRequested extends ProfileEvent {
  final String userId;

  const ProfileLoadMorePostsRequested({required this.userId});
}

class ProfileLoadMoreMediaRequested extends ProfileEvent {
  final String userId;

  const ProfileLoadMoreMediaRequested({required this.userId});
}

class ProfileUpdateRequested extends ProfileEvent {
  final UserEntity updatedUser;

  const ProfileUpdateRequested({required this.updatedUser});
}
