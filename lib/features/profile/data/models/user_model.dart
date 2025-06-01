// lib/features/profile/data/models/user_model.dart
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      profilePicture:
          json['profile_pic'] as String?,
      coverPicture: json['cover_pic'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      socialLinks: json['social_links'] != null
          ? Map<String, String>.from(json['social_links'] as Map)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ??
          true, // Default to active if not provided
      isPremium: json['is_premium'] as bool? ?? false,
      isPrivate: json['is_private'] as bool? ?? false,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      friendsCount: json['friends_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(), // Default to current time if not provided
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
