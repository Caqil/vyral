abstract class FollowingEvent {
  const FollowingEvent();
}

class FollowingLoadRequested extends FollowingEvent {
  final String userId;
  const FollowingLoadRequested({required this.userId});
}

class FollowingRefreshRequested extends FollowingEvent {
  final String userId;
  const FollowingRefreshRequested({required this.userId});
}

class FollowingLoadMoreRequested extends FollowingEvent {
  final String userId;
  const FollowingLoadMoreRequested({required this.userId});
}

class FollowingUnfollowRequested extends FollowingEvent {
  final String userId;
  final String targetUserId;
  const FollowingUnfollowRequested({
    required this.userId,
    required this.targetUserId,
  });
}
