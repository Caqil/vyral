import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'display_name')
  final String? displayName;
  final String? bio;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'cover_picture')
  final String? coverPicture;
  final String? website;
  final String? location;
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  @JsonKey(name: 'social_links')
  final Map<String, String>? socialLinks;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_premium')
  final bool isPremium;
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
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.displayName,
    this.bio,
    this.profilePicture,
    this.coverPicture,
    this.website,
    this.location,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.socialLinks,
    required this.isVerified,
    required this.isActive,
    this.isPremium = false,
    this.isPrivate = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.friendsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        firstName,
        lastName,
        displayName,
        bio,
        profilePicture,
        coverPicture,
        website,
        location,
        dateOfBirth,
        gender,
        phone,
        socialLinks,
        isVerified,
        isActive,
        isPremium,
        isPrivate,
        followersCount,
        followingCount,
        postsCount,
        friendsCount,
        createdAt,
        updatedAt,
      ];

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? username;
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? displayName,
    String? bio,
    String? profilePicture,
    String? coverPicture,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    Map<String, String>? socialLinks,
    bool? isVerified,
    bool? isActive,
    bool? isPremium,
    bool? isPrivate,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    int? friendsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      coverPicture: coverPicture ?? this.coverPicture,
      website: website ?? this.website,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      socialLinks: socialLinks ?? this.socialLinks,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      isPrivate: isPrivate ?? this.isPrivate,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      friendsCount: friendsCount ?? this.friendsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
