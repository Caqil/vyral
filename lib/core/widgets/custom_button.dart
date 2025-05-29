// lib/core/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum ButtonType { primary, secondary, outline, text, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = AppConstants.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getBackgroundColor() {
      if (backgroundColor != null) return backgroundColor!;
      
      switch (type) {
        case ButtonType.primary:
          return colorScheme.primary;
        case ButtonType.secondary:
          return colorScheme.secondary;
        case ButtonType.outline:
        case ButtonType.text:
          return Colors.transparent;
        case ButtonType.danger:
          return colorScheme.error;
      }
    }

    Color getTextColor() {
      if (textColor != null) return textColor!;
      
      switch (type) {
        case ButtonType.primary:
          return colorScheme.onPrimary;
        case ButtonType.secondary:
          return colorScheme.onSecondary;
        case ButtonType.outline:
          return colorScheme.primary;
        case ButtonType.text:
          return colorScheme.primary;
        case ButtonType.danger:
          return colorScheme.onError;
      }
    }

    BorderSide? getBorderSide() {
      switch (type) {
        case ButtonType.outline:
          return BorderSide(color: colorScheme.primary, width: 1.5);
        case ButtonType.danger when type == ButtonType.outline:
          return BorderSide(color: colorScheme.error, width: 1.5);
        default:
          return null;
      }
    }

    Widget buildChild() {
      if (isLoading) {
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
          ),
        );
      }

      if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: getTextColor()),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: getTextColor(),
              ),
            ),
          ],
        );
      }

      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: getTextColor(),
        ),
      );
    }

    Widget button;

    if (type == ButtonType.text) {
      button = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: buildChild(),
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: getBorderSide() ?? BorderSide.none,
          ),
          elevation: type == ButtonType.outline ? 0 : 2,
        ),
        child: buildChild(),
      );
    }

    if (isFullWidth) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 50,
        child: button,
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 50,
      child: button,
    );
  }
}
