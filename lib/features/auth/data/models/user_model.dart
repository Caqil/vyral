import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  @JsonKey(name: 'profile_pic')
  final String? profilePic;
  @JsonKey(name: 'cover_pic')
  final String? coverPic;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_private')
  final bool isPrivate;
  @JsonKey(name: 'followers_count')
  final int followersCount;
  @JsonKey(name: 'following_count')
  final int followingCount;
  @JsonKey(name: 'posts_count')
  final int postsCount;
  @JsonKey(name: 'friends_count')
  final int friendsCount;
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const UserModel({
    required String id,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? bio,
    this.profilePic,
    this.coverPic,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    Map<String, String>? socialLinks,
    required this.isVerified,
    required this.isPrivate,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.friendsCount,
    required this.isPremium,
    required this.createdAt,
  }) : super(
          id: id,
          email: email,
          username: username,
          firstName: firstName,
          lastName: lastName,
          displayName: displayName,
          bio: bio,
          profilePicture: profilePic,
          website: website,
          location: location,
          dateOfBirth: dateOfBirth,
          gender: gender,
          phone: phone,
          socialLinks: socialLinks,
          isVerified: isVerified,
          isActive: !isPrivate, // Assuming active means not private
          createdAt: createdAt,
          updatedAt: createdAt, // Using created_at as fallback
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      username: entity.username,
      firstName: entity.firstName,
      lastName: entity.lastName,
      displayName: entity.displayName,
      bio: entity.bio,
      profilePic: entity.profilePicture,
      website: entity.website,
      location: entity.location,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      phone: entity.phone,
      socialLinks: entity.socialLinks,
      isVerified: entity.isVerified,
      isPrivate: !entity.isActive,
      followersCount: 0, // Default values for counts
      followingCount: 0,
      postsCount: 0,
      friendsCount: 0,
      isPremium: false,
      createdAt: entity.createdAt,
    );
  }

  // Additional getters for your API-specific fields
  int get totalConnections => followersCount + followingCount + friendsCount;
  bool get hasProfilePicture => profilePic != null && profilePic!.isNotEmpty;
  bool get hasCoverPicture => coverPic != null && coverPic!.isNotEmpty;
}
