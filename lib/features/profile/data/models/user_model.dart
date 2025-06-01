import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    super.firstName,
    super.lastName,
    super.displayName,
    super.bio,
    super.profilePicture,
    super.coverPicture,
    super.website,
    super.location,
    super.dateOfBirth,
    super.gender,
    super.phone,
    super.socialLinks,
    required super.isVerified,
    required super.isActive,
    super.isPremium,
    super.isPrivate,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.friendsCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
