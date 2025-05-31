// lib/app/theme/colors.dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppColors {
  // Shadcn UI theme names - these are the built-in themes
  static const List<String> availableThemes = [
    'blue',
    'gray',
    'green',
    'neutral',
    'orange',
    'red',
    'rose',
    'slate',
    'stone',
    'violet',
    'yellow',
    'zinc',
  ];

  // Default theme name
  static const String defaultTheme = 'zinc';

  // Get light color scheme for given theme name
  static ShadColorScheme getLightColorScheme(
      [String themeName = defaultTheme]) {
    return ShadColorScheme.fromName(themeName, brightness: Brightness.light);
  }

  // Get dark color scheme for given theme name
  static ShadColorScheme getDarkColorScheme([String themeName = defaultTheme]) {
    return ShadColorScheme.fromName(themeName, brightness: Brightness.dark);
  }

  // Custom colors that can be used alongside shadcn themes
  // These maintain your original brand colors as backups
  static const Color primaryCustom = Color(0xFF6366F1); // Indigo
  static const Color primaryLightCustom = Color(0xFF818CF8);
  static const Color primaryDarkCustom = Color(0xFF4F46E5);

  static const Color secondaryCustom = Color(0xFF10B981); // Emerald
  static const Color secondaryLightCustom = Color(0xFF34D399);
  static const Color secondaryDarkCustom = Color(0xFF059669);

  static const Color errorCustom = Color(0xFFEF4444); // Red
  static const Color errorLightCustom = Color(0xFFF87171);
  static const Color errorDarkCustom = Color(0xFFDC2626);

  static const Color warningCustom = Color(0xFFF59E0B); // Amber
  static const Color warningLightCustom = Color(0xFFFBBF24);
  static const Color warningDarkCustom = Color(0xFFD97706);

  static const Color successCustom = Color(0xFF10B981); // Emerald
  static const Color successLightCustom = Color(0xFF34D399);
  static const Color successDarkCustom = Color(0xFF059669);

  static const Color infoCustom = Color(0xFF3B82F6); // Blue
  static const Color infoLightCustom = Color(0xFF60A5FA);
  static const Color infoDarkCustom = Color(0xFF2563EB);

  // Neutral colors for custom implementations
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral950 = Color(0xFF0A0A0A);

  // Create custom shadcn color scheme with your brand colors
  static ShadColorScheme createCustomColorScheme({
    required Brightness brightness,
    Color? primary,
    Color? secondary,
  }) {
    final bool isDark = brightness == Brightness.dark;

    return ShadColorScheme(
      background: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
      foreground: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      card: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
      cardForeground:
          isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      popover: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
      popoverForeground:
          isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      primary: primary ?? (isDark ? primaryLightCustom : primaryCustom),
      primaryForeground:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      secondary: secondary ?? (isDark ? secondaryLightCustom : secondaryCustom),
      secondaryForeground:
          isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      muted: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      mutedForeground:
          isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      accent: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      accentForeground:
          isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      destructive: isDark ? errorLightCustom : errorCustom,
      destructiveForeground: const Color(0xFFF8FAFC),
      border: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      input: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ring: primary ?? (isDark ? primaryLightCustom : primaryCustom),
      selection: (primary ?? (isDark ? primaryLightCustom : primaryCustom))
          .withOpacity(0.2),
    );
  }

  // Gradient colors
  static const List<Color> primaryGradient = [
    primaryLightCustom,
    primaryCustom
  ];
  static const List<Color> secondaryGradient = [
    secondaryLightCustom,
    secondaryCustom
  ];
  static const List<Color> errorGradient = [errorLightCustom, errorCustom];
  static const List<Color> successGradient = [
    successLightCustom,
    successCustom
  ];

}
