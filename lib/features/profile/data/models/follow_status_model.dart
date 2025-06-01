import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/follow_status_entity.dart';
part 'follow_status_model.g.dart';

@JsonSerializable()
class FollowStatusModel extends FollowStatusEntity {
  const FollowStatusModel({
    required super.userId,
    required super.targetUserId,
    required super.isFollowing,
    required super.isFollowedBy,
    required super.isPending,
    required super.isBlocked,
    required super.isMuted,
    super.followedAt,
    super.updatedAt,
  });

  factory FollowStatusModel.fromJson(Map<String, dynamic> json) {
    return FollowStatusModel(
      userId: json['user_id'] as String,
      targetUserId: json['target_user_id'] as String,
      isFollowing: json['is_following'] as bool? ?? false,
      isFollowedBy: json['is_followed_by'] as bool? ?? false,
      isPending: json['is_pending'] as bool? ?? false,
      isBlocked: json['is_blocked'] as bool? ?? false,
      isMuted: json['is_muted'] as bool? ?? false,
      followedAt: json['followed_at'] != null
          ? DateTime.parse(json['followed_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$FollowStatusModelToJson(this);
}
