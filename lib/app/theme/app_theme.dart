import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme),
      tabBarTheme: _buildTabBarTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme),
      snackBarTheme: _buildSnackBarTheme(colorScheme),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      error: AppColors.errorLight,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colorScheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme),
      tabBarTheme: _buildTabBarTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme),
      snackBarTheme: _buildSnackBarTheme(colorScheme),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge:
          AppTextStyles.displayLarge.copyWith(color: colorScheme.onSurface),
      displayMedium:
          AppTextStyles.displayMedium.copyWith(color: colorScheme.onSurface),
      displaySmall:
          AppTextStyles.displaySmall.copyWith(color: colorScheme.onSurface),
      headlineLarge:
          AppTextStyles.headlineLarge.copyWith(color: colorScheme.onSurface),
      headlineMedium:
          AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface),
      headlineSmall:
          AppTextStyles.headlineSmall.copyWith(color: colorScheme.onSurface),
      titleLarge:
          AppTextStyles.titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium:
          AppTextStyles.titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall:
          AppTextStyles.titleSmall.copyWith(color: colorScheme.onSurface),
      labelLarge:
          AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurface),
      labelMedium: AppTextStyles.labelMedium
          .copyWith(color: colorScheme.onSurfaceVariant),
      labelSmall: AppTextStyles.labelSmall
          .copyWith(color: colorScheme.onSurfaceVariant),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium:
          AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
      bodySmall:
          AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: true,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      systemOverlayStyle: colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
      ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.button,
        elevation: 2,
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
      ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.button,
        side: BorderSide(color: colorScheme.outline),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
      ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      labelStyle: AppTextStyles.labelLarge
          .copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: AppTextStyles.bodyMedium
          .copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  static CardThemeData _buildCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surface,
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
      ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(
      ColorScheme colorScheme) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withOpacity(0.12),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.labelSmall.copyWith(color: colorScheme.primary);
        }
        return AppTextStyles.labelSmall
            .copyWith(color: colorScheme.onSurfaceVariant);
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: colorScheme.primary);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant);
      }),
    );
  }

  static TabBarThemeData _buildTabBarTheme(ColorScheme colorScheme) {
    return TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      labelStyle: AppTextStyles.titleSmall,
      unselectedLabelStyle: AppTextStyles.titleSmall,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  static ChipThemeData _buildChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceVariant,
      selectedColor: colorScheme.primary.withOpacity(0.12),
      labelStyle:
          AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static DialogThemeData _buildDialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
      backgroundColor: colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle:
          AppTextStyles.headlineSmall.copyWith(color: colorScheme.onSurface),
      contentTextStyle:
          AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: AppTextStyles.bodyMedium
          .copyWith(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  static FloatingActionButtonThemeData _buildFloatingActionButtonTheme(
      ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outline.withOpacity(0.2),
      thickness: 1,
    );
  }
}
