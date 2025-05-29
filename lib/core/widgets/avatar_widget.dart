import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/helpers.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor =
        backgroundColor ?? Helpers.getAvatarColor(name);
    final defaultTextColor =
        textColor ?? Helpers.getContrastingTextColor(defaultBackgroundColor);

    Widget avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: defaultBackgroundColor,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              Helpers.getInitials(name),
              style: TextStyle(
                color: defaultTextColor,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );

    if (showBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? theme.colorScheme.outline,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}
