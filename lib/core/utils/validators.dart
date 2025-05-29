// lib/core/utils/validators.dart
class Validators {
  // Email validation
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Username validation
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (username.length > 30) {
      return 'Username must be less than 30 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_.-]+$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, dots, hyphens, and underscores';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? name, {String fieldName = 'Name'}) {
    if (name == null || name.isEmpty) {
      return '$fieldName is required';
    }

    if (name.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    if (name.length > 50) {
      return '$fieldName must be less than 50 characters';
    }

    final nameRegex = RegExp(r'^[a-zA-Z0-9_.-]+$');
    if (!nameRegex.hasMatch(name)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength,
      {String fieldName = 'Field'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength,
      {String fieldName = 'Field'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  // Bio validation
  static String? validateBio(String? bio) {
    if (bio == null || bio.isEmpty) {
      return null; // Bio is optional
    }

    if (bio.length > 500) {
      return 'Bio must be less than 500 characters';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

    if (!urlRegex.hasMatch(url)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Age validation (for date of birth)
  static String? validateAge(DateTime? dateOfBirth,
      {int minAge = 13, int maxAge = 120}) {
    if (dateOfBirth == null) {
      return null; // Optional field
    }

    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;

    if (dateOfBirth.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }

    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }

    if (age > maxAge) {
      return 'Please enter a valid date of birth';
    }

    return null;
  }
}
