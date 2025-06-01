// lib/features/profile/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? bio;
  final String? profilePicture;
  final String? coverPicture;
  final String? website;
  final String? location;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final Map<String, String>? socialLinks;
  final bool isVerified;
  final bool isActive;
  final bool isPremium;
  final bool isPrivate;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int friendsCount;
  final DateTime createdAt;
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


