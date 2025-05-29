// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      profilePic: json['profile_pic'] as String?,
      coverPic: json['cover_pic'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      isVerified: json['is_verified'] as bool,
      isPrivate: json['is_private'] as bool,
      followersCount: (json['followers_count'] as num).toInt(),
      followingCount: (json['following_count'] as num).toInt(),
      postsCount: (json['posts_count'] as num).toInt(),
      friendsCount: (json['friends_count'] as num).toInt(),
      isPremium: json['is_premium'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'website': instance.website,
      'location': instance.location,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'phone': instance.phone,
      'socialLinks': instance.socialLinks,
      'profile_pic': instance.profilePic,
      'cover_pic': instance.coverPic,
      'is_verified': instance.isVerified,
      'is_private': instance.isPrivate,
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'posts_count': instance.postsCount,
      'friends_count': instance.friendsCount,
      'is_premium': instance.isPremium,
      'created_at': instance.createdAt.toIso8601String(),
    };
