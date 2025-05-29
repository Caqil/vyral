// lib/features/auth/domain/entities/user_entity.dart
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
  final String? website;
  final String? location;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;
  final Map<String, String>? socialLinks;
  final bool isVerified;
  final bool isActive;
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
    this.website,
    this.location,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.socialLinks,
    required this.isVerified,
    required this.isActive,
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
        website,
        location,
        dateOfBirth,
        gender,
        phone,
        socialLinks,
        isVerified,
        isActive,
        createdAt,
        updatedAt,
      ];

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? username;
  }
}
