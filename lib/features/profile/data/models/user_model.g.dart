// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profilePicture'] as String?,
      coverPicture: json['coverPicture'] as String?,
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
      isVerified: json['isVerified'] as bool,
      isActive: json['isActive'] as bool,
      isPremium: json['isPremium'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      friendsCount: (json['friendsCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'profilePicture': instance.profilePicture,
      'coverPicture': instance.coverPicture,
      'website': instance.website,
      'location': instance.location,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'phone': instance.phone,
      'socialLinks': instance.socialLinks,
      'isVerified': instance.isVerified,
      'isActive': instance.isActive,
      'isPremium': instance.isPremium,
      'isPrivate': instance.isPrivate,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'postsCount': instance.postsCount,
      'friendsCount': instance.friendsCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
