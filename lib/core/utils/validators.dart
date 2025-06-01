
import 'package:vyral/core/utils/extensions.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.isValidEmail) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Name fields are often optional
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$fieldName can only contain letters and spaces';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    if (value.startsWith('_') || value.endsWith('_')) {
      return 'Username cannot start or end with an underscore';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is often optional
    }
    if (!value.isValidPhone) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is often optional
    }
    if (!value.isValidUrl) {
      return 'Please enter a valid URL (e.g., https://example.com)';
    }
    return null;
  }

  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }
    if (value.length > 500) {
      return 'Bio must be less than 500 characters';
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    if (value.trim().length < 1) {
      return 'Display name is required';
    }
    if (value.trim().length > 50) {
      return 'Display name must be less than 50 characters';
    }
    return null;
  }

  static String? validateAge(DateTime? dateOfBirth, {int minAge = 13}) {
    if (dateOfBirth == null) {
      return null; // Date of birth is often optional
    }
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    final hasHadBirthdayThisYear = now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);
    
    final actualAge = hasHadBirthdayThisYear ? age : age - 1;
    
    if (actualAge < minAge) {
      return 'You must be at least $minAge years old';
    }
    if (actualAge > 120) {
      return 'Please enter a valid date of birth';
    }
    return null;
  }
}