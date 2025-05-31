// lib/app/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  // Available theme names from shadcn_ui
  static const List<String> availableThemes = AppColors.availableThemes;
  static const String defaultTheme = AppColors.defaultTheme;

  // Get light theme with shadcn_ui integration
  static ShadThemeData getLightTheme([String themeName = defaultTheme]) {
    final colorScheme = AppColors.getLightColorScheme(themeName);
    return _buildShadTheme(colorScheme, Brightness.light);
  }

  // Get dark theme with shadcn_ui integration
  static ShadThemeData getDarkTheme([String themeName = defaultTheme]) {
    final colorScheme = AppColors.getDarkColorScheme(themeName);
    return _buildShadTheme(colorScheme, Brightness.dark);
  }

  // Get custom theme with your brand colors
  static ShadThemeData getCustomLightTheme() {
    final colorScheme = AppColors.createCustomColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryCustom,
      secondary: AppColors.secondaryCustom,
    );
    return _buildShadTheme(colorScheme, Brightness.light);
  }

  static ShadThemeData getCustomDarkTheme() {
    final colorScheme = AppColors.createCustomColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLightCustom,
      secondary: AppColors.secondaryLightCustom,
    );
    return _buildShadTheme(colorScheme, Brightness.dark);
  }

  // Build ShadThemeData with comprehensive theming
  static ShadThemeData _buildShadTheme(
      ShadColorScheme colorScheme, Brightness brightness) {
    return ShadThemeData(
      brightness: brightness,
      colorScheme: colorScheme,

      // Text theme
      textTheme: AppTextStyles.createShadTextTheme(colorScheme),

      // Radius for rounded corners (shadcn standard is 0.5rem = 8px)
      radius: BorderRadius.circular(8),

      // Component themes
      primaryButtonTheme:
          _buildButtonTheme(colorScheme, ShadButtonVariant.primary),
      secondaryButtonTheme:
          _buildButtonTheme(colorScheme, ShadButtonVariant.secondary),
      destructiveButtonTheme:
          _buildButtonTheme(colorScheme, ShadButtonVariant.destructive),
      outlineButtonTheme:
          _buildButtonTheme(colorScheme, ShadButtonVariant.outline),
      ghostButtonTheme: _buildButtonTheme(colorScheme, ShadButtonVariant.ghost),
      linkButtonTheme: _buildButtonTheme(colorScheme, ShadButtonVariant.link),

      // Input theme
      inputTheme: _buildInputTheme(colorScheme),

      // Card theme
      cardTheme: _buildCardTheme(colorScheme),

      // Avatar theme
      avatarTheme: _buildAvatarTheme(colorScheme),

      // Checkbox theme
      checkboxTheme: _buildCheckboxTheme(colorScheme),

      // Radio theme
      radioTheme: _buildRadioTheme(colorScheme),

      // Switch theme
      switchTheme: _buildSwitchTheme(colorScheme),

      // Select theme
      selectTheme: _buildSelectTheme(colorScheme),

      // Slider theme
      sliderTheme: _buildSliderTheme(colorScheme),

      // Progress theme
      progressTheme: _buildProgressTheme(colorScheme),

      // Tooltip theme
      tooltipTheme: _buildTooltipTheme(colorScheme),

      // Popover theme
      popoverTheme: _buildPopoverTheme(colorScheme),

      // Sheet theme
      sheetTheme: _buildSheetTheme(colorScheme),

      // Accordion theme
      accordionTheme: _buildAccordionTheme(colorScheme),

      // Calendar theme
      calendarTheme: _buildCalendarTheme(colorScheme),

      // Context menu theme
      contextMenuTheme: _buildContextMenuTheme(colorScheme),

      // Disable secondary border if you prefer single border focus
      disableSecondaryBorder: false,
    );
  }

  // Component theme builders
  static ShadButtonTheme _buildButtonTheme(
      ShadColorScheme colorScheme, ShadButtonVariant variant) {
    return ShadButtonTheme(
      cursor: SystemMouseCursors.click,
      gap: 8,
      decoration: ShadDecoration(
        border: ShadBorder(radius: BorderRadius.circular(6)),
      ),
    );
  }

  static ShadInputTheme _buildInputTheme(ShadColorScheme colorScheme) {
    return ShadInputTheme(
      style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.foreground),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: colorScheme.border,
          width: 1,
        ),
      ),
      placeholderStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.mutedForeground,
      ),
    );
  }

  static ShadCardTheme _buildCardTheme(ShadColorScheme colorScheme) {
    return ShadCardTheme(
      backgroundColor: colorScheme.card,
      padding: const EdgeInsets.all(24),
      
    );
  }

  static ShadDialogTheme _buildDialogTheme(ShadColorScheme colorScheme) {
    return ShadDialogTheme(
      backgroundColor: colorScheme.background,
      removeBorderRadiusWhenTiny: true,
      titleStyle: AppTextStyles.h4.copyWith(color: colorScheme.foreground),
      descriptionStyle:
          AppTextStyles.muted.copyWith(color: colorScheme.mutedForeground),
      padding: const EdgeInsets.all(24),
      gap: 16,
      
    );
  }

  static ShadAlertTheme _buildAlertTheme(ShadColorScheme colorScheme) {
    return ShadAlertTheme(
      iconPadding: const EdgeInsets.only(right: 12),
      titleStyle:
          AppTextStyles.titleMedium.copyWith(color: colorScheme.foreground),
      descriptionStyle:
          AppTextStyles.bodyMedium.copyWith(color: colorScheme.foreground),
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: colorScheme.border,
          width: 1,
        ),
      ),
    );
  }

  static ShadBadgeTheme _buildBadgeTheme(ShadColorScheme colorScheme) {
    return ShadBadgeTheme(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
     
    );
  }

  static ShadAvatarTheme _buildAvatarTheme(ShadColorScheme colorScheme) {
    return ShadAvatarTheme(
      size: const Size.square(40),
    );
  }

  static ShadCheckboxTheme _buildCheckboxTheme(ShadColorScheme colorScheme) {
    return ShadCheckboxTheme(
      size: 16,
      duration: const Duration(milliseconds: 150),
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: colorScheme.border,
          width: 1,
        ),
      ),
    );
  }

  static ShadRadioTheme _buildRadioTheme(ShadColorScheme colorScheme) {
    return ShadRadioTheme(
      size: 16,
      duration: const Duration(milliseconds: 150),
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: colorScheme.border,
          width: 1,
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  static ShadSwitchTheme _buildSwitchTheme(ShadColorScheme colorScheme) {
    return ShadSwitchTheme(
      width: 44,
      height: 24,
      duration: const Duration(milliseconds: 150),
      thumbColor: colorScheme.background,
    );
  }

  static ShadSelectTheme _buildSelectTheme(ShadColorScheme colorScheme) {
    return ShadSelectTheme(
      minWidth: 180,
      maxHeight: 300,
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: colorScheme.border,
          width: 1,
        ),
      ),
      optionsPadding: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showScrollToTopChevron: true,
      showScrollToBottomChevron: true,
    );
  }

  static ShadSliderTheme _buildSliderTheme(ShadColorScheme colorScheme) {
    return ShadSliderTheme(
      min: 0,
      max: 100,
      thumbColor: colorScheme.primary,
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.secondary,
      thumbRadius: 10,
      trackHeight: 4,
      mouseCursor: SystemMouseCursors.click,
    );
  }

  static ShadProgressTheme _buildProgressTheme(ShadColorScheme colorScheme) {
    return ShadProgressTheme(
      minHeight: 8,
      color: colorScheme.primary,
      backgroundColor: colorScheme.secondary,
      borderRadius: BorderRadius.circular(4),
    );
  }

  static ShadTooltipTheme _buildTooltipTheme(ShadColorScheme colorScheme) {
    return ShadTooltipTheme(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 200)),
      ],
      decoration: ShadDecoration(
        color: colorScheme.foreground,
      ),
     
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  static ShadPopoverTheme _buildPopoverTheme(ShadColorScheme colorScheme) {
    return ShadPopoverTheme(
      decoration: ShadDecoration(
        color: colorScheme.popover,
        border: ShadBorder.all(
          color: colorScheme.border,
          width: 1,
        ),
        shadows: [
          BoxShadow(
            color: colorScheme.foreground.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
    );
  }

  static ShadSheetTheme _buildSheetTheme(ShadColorScheme colorScheme) {
    return ShadSheetTheme(
      backgroundColor: colorScheme.background,
      gap: 16,
      padding: const EdgeInsets.all(24),
     
    );
  }

  static ShadToastTheme _buildToastTheme(ShadColorScheme colorScheme) {
    return ShadToastTheme(
      titleStyle:
          AppTextStyles.titleSmall.copyWith(color: colorScheme.foreground),
      descriptionStyle:
          AppTextStyles.bodySmall.copyWith(color: colorScheme.mutedForeground),
      actionPadding: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(16),
      
    );
  }

  static ShadAccordionTheme _buildAccordionTheme(ShadColorScheme colorScheme) {
    return ShadAccordionTheme(
      titleStyle:
          AppTextStyles.titleMedium.copyWith(color: colorScheme.foreground),
      padding: const EdgeInsets.symmetric(vertical: 16),
      underlineTitleOnHover: false,
      duration: const Duration(milliseconds: 200),
    );
  }

  static ShadCalendarTheme _buildCalendarTheme(ShadColorScheme colorScheme) {
    return ShadCalendarTheme(
      headerHeight: 40,
      weekdaysPadding: const EdgeInsets.symmetric(vertical: 8),
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: colorScheme.border,
          width: 1,
        ),
      ),
      headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      spacingBetweenMonths: 32,
    );
  }

  static ShadContextMenuTheme _buildContextMenuTheme(
      ShadColorScheme colorScheme) {
    return ShadContextMenuTheme(
      decoration: ShadDecoration(
        color: colorScheme.background,
        border: ShadBorder.all(
          color: colorScheme.border,
          width: 1,
        ),
        shadows: [
          BoxShadow(
            color: colorScheme.foreground.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
    );
  }


  // Material theme builders for backward compatibility
  static AppBarTheme _buildMaterialAppBarTheme(ColorScheme colorScheme) {
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

  static ElevatedButtonThemeData _buildMaterialElevatedButtonTheme(
      ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.button,
        elevation: 2,
      ),
    );
  }

  static TextButtonThemeData _buildMaterialTextButtonTheme(
      ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static OutlinedButtonThemeData _buildMaterialOutlinedButtonTheme(
      ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.button,
        side: BorderSide(color: colorScheme.outline),
      ),
    );
  }

  static InputDecorationTheme _buildMaterialInputDecorationTheme(
      ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      labelStyle: AppTextStyles.labelLarge
          .copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: AppTextStyles.bodyMedium
          .copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  static CardThemeData _buildMaterialCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface,
    );
  }
}
