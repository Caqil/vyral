import 'dart:ui';

import 'package:flutter/material.dart';

class Helpers {
  static String formatNumber(int number) {
    if (number >= 1000000) {
      final millions = number / 1000000;
      return '${_formatDecimal(millions)}M';
    } else if (number >= 1000) {
      final thousands = number / 1000;
      return '${_formatDecimal(thousands)}K';
    } else {
      return number.toString();
    }
  }

  static String _formatDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }

  static Color generateColorFromString(String text) {
    final hash = text.hashCode;
    final hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.6, 0.8).toColor();
  }

  static String generateUsername(String firstName, String lastName) {
    final base = '${firstName.toLowerCase()}${lastName.toLowerCase()}';
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    return '${base}_$random';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  static List<T> paginate<T>(List<T> items, int page, int pageSize) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, items.length);

    if (startIndex >= items.length) {
      return [];
    }

    return items.sublist(startIndex, endIndex);
  }

  static String obfuscateEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 2) {
      return email; // Don't obfuscate very short emails
    }

    final obfuscatedLocal =
        '${localPart[0]}${'*' * (localPart.length - 2)}${localPart[localPart.length - 1]}';
    return '$obfuscatedLocal@$domain';
  }

  static String obfuscatePhone(String phone) {
    if (phone.length <= 4) return phone;

    final visibleDigits = 2;
    final start = phone.substring(0, visibleDigits);
    final end = phone.substring(phone.length - visibleDigits);
    final middle = '*' * (phone.length - visibleDigits * 2);

    return '$start$middle$end';
  }
}
