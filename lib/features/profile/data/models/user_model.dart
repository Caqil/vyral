// lib/features/profile/data/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:vyral/core/utils/logger.dart';
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
    try {
      // Handle required fields with null safety
      final String id = json['id']?.toString() ?? '';
      final String email = json['email']?.toString() ?? '';
      final String username = json['username']?.toString() ?? 'unknown_user';

      // Handle optional string fields
      String? firstName = json['first_name']?.toString();
      if (firstName?.isEmpty == true) firstName = null;

      String? lastName = json['last_name']?.toString();
      if (lastName?.isEmpty == true) lastName = null;

      String? displayName = json['display_name']?.toString();
      if (displayName?.isEmpty == true) displayName = null;

      String? bio = json['bio']?.toString();
      if (bio?.isEmpty == true) bio = null;

      String? profilePicture = json['profile_pic']?.toString() ??
          json['profile_picture']?.toString();
      if (profilePicture?.isEmpty == true) profilePicture = null;

      String? coverPicture =
          json['cover_pic']?.toString() ?? json['cover_picture']?.toString();
      if (coverPicture?.isEmpty == true) coverPicture = null;

      String? website = json['website']?.toString();
      if (website?.isEmpty == true) website = null;

      String? location = json['location']?.toString();
      if (location?.isEmpty == true) location = null;

      String? gender = json['gender']?.toString();
      if (gender?.isEmpty == true) gender = null;

      String? phone = json['phone']?.toString();
      if (phone?.isEmpty == true) phone = null;

      // Handle date of birth
      DateTime? dateOfBirth;
      if (json['date_of_birth'] != null) {
        try {
          final dobString = json['date_of_birth'].toString();
          if (dobString.isNotEmpty && dobString != '0001-01-01T00:00:00Z') {
            dateOfBirth = DateTime.parse(dobString);
          }
        } catch (e) {
          AppLogger.debug('Error parsing date_of_birth: $e');
        }
      }

      // Handle social links
      Map<String, String>? socialLinks;
      if (json['social_links'] != null && json['social_links'] is Map) {
        socialLinks = Map<String, String>.from(json['social_links'] as Map);
      }

      // Handle boolean fields with defaults
      final bool isVerified = json['is_verified'] as bool? ?? false;
      final bool isActive = json['is_active'] as bool? ?? true;
      final bool isPremium = json['is_premium'] as bool? ?? false;
      final bool isPrivate = json['is_private'] as bool? ?? false;

      // Handle count fields
      final int followersCount =
          (json['followers_count'] as num?)?.toInt() ?? 0;
      final int followingCount =
          (json['following_count'] as num?)?.toInt() ?? 0;
      final int postsCount = (json['posts_count'] as num?)?.toInt() ?? 0;
      final int friendsCount = (json['friends_count'] as num?)?.toInt() ?? 0;

      // Handle required dates
      DateTime createdAt = DateTime.now();
      if (json['created_at'] != null) {
        try {
          final createdAtString = json['created_at'].toString();
          if (createdAtString.isNotEmpty &&
              createdAtString != '0001-01-01T00:00:00Z') {
            createdAt = DateTime.parse(createdAtString);
          }
        } catch (e) {
          AppLogger.debug('Error parsing created_at: $e');
        }
      }

      DateTime updatedAt = createdAt;
      if (json['updated_at'] != null) {
        try {
          final updatedAtString = json['updated_at'].toString();
          if (updatedAtString.isNotEmpty &&
              updatedAtString != '0001-01-01T00:00:00Z') {
            updatedAt = DateTime.parse(updatedAtString);
          }
        } catch (e) {
          AppLogger.debug('Error parsing updated_at: $e');
        }
      }

      return UserModel(
        id: id,
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        bio: bio,
        profilePicture: profilePicture,
        coverPicture: coverPicture,
        website: website,
        location: location,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        socialLinks: socialLinks,
        isVerified: isVerified,
        isActive: isActive,
        isPremium: isPremium,
        isPrivate: isPrivate,
        followersCount: followersCount,
        followingCount: followingCount,
        postsCount: postsCount,
        friendsCount: friendsCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      AppLogger.debug('Error parsing UserModel from JSON: $e');
      AppLogger.debug('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
