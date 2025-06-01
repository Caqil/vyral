// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profile_picture'] as String?,
      coverPicture: json['cover_picture'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      socialLinks: (json['social_links'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      isVerified: json['is_verified'] as bool,
      isActive: json['is_active'] as bool,
      isPremium: json['is_premium'] as bool? ?? false,
      isPrivate: json['is_private'] as bool? ?? false,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
      friendsCount: (json['friends_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'profile_picture': instance.profilePicture,
      'cover_picture': instance.coverPicture,
      'website': instance.website,
      'location': instance.location,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'phone': instance.phone,
      'social_links': instance.socialLinks,
      'is_verified': instance.isVerified,
      'is_active': instance.isActive,
      'is_premium': instance.isPremium,
      'is_private': instance.isPrivate,
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'posts_count': instance.postsCount,
      'friends_count': instance.friendsCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
