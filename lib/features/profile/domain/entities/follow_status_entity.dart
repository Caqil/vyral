import 'package:equatable/equatable.dart';

class FollowStatusEntity extends Equatable {
  final String userId;
  final String targetUserId;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isPending;
  final bool isBlocked;
  final bool isMuted;
  final DateTime? followedAt;
  final DateTime? updatedAt;

  const FollowStatusEntity({
    required this.userId,
    required this.targetUserId,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isPending,
    required this.isBlocked,
    required this.isMuted,
    this.followedAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        targetUserId,
        isFollowing,
        isFollowedBy,
        isPending,
        isBlocked,
        isMuted,
        followedAt,
        updatedAt,
      ];

  bool get canFollow => !isFollowing && !isPending && !isBlocked;
  bool get canMessage => !isBlocked && (isFollowedBy || !isPending);
}
