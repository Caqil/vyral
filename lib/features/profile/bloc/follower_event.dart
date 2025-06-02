abstract class FollowersEvent {
  const FollowersEvent();
}

class FollowersLoadRequested extends FollowersEvent {
  final String userId;
  const FollowersLoadRequested({required this.userId});
}

class FollowersRefreshRequested extends FollowersEvent {
  final String userId;
  const FollowersRefreshRequested({required this.userId});
}

class FollowersLoadMoreRequested extends FollowersEvent {
  final String userId;
  const FollowersLoadMoreRequested({required this.userId});
}
