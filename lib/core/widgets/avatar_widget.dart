// lib/core/widgets/avatar_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;
  final bool showOnlineStatus;
  final bool isOnline;
  final bool showPrivateIcon;
  final Widget? customPlaceholder;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.onTap,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.showPrivateIcon = false,
    this.customPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.muted,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty && !showPrivateIcon
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    _buildPlaceholder(context, colorScheme),
                errorWidget: (context, url, error) =>
                    _buildPlaceholder(context, colorScheme),
              )
            : _buildPlaceholder(context, colorScheme),
      ),
    );

    // Add online status indicator
    if (showOnlineStatus || showPrivateIcon) {
      avatar = Stack(
        children: [
          avatar,
          if (showOnlineStatus)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? Colors.green : Colors.grey,
                  border: Border.all(
                    color: colorScheme.background,
                    width: size * 0.04,
                  ),
                ),
              ),
            ),
          if (showPrivateIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.muted,
                  border: Border.all(
                    color: colorScheme.background,
                    width: size * 0.04,
                  ),
                ),
                child: Icon(
                  LucideIcons.lock,
                  size: size * 0.15,
                  color: colorScheme.mutedForeground,
                ),
              ),
            ),
        ],
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

  Widget _buildPlaceholder(BuildContext context, ShadColorScheme colorScheme) {
    if (customPlaceholder != null) {
      return customPlaceholder!;
    }

    if (showPrivateIcon) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.muted,
        ),
        child: Icon(
          LucideIcons.user,
          size: size * 0.5,
          color: colorScheme.mutedForeground.withOpacity(0.5),
        ),
      );
    }

    // Generate initials from name
    final initials = _getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            _getColorFromName(name),
            _getColorFromName(name).withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  Color _getColorFromName(String name) {
    // Generate a color based on the name for consistent avatar colors
    final hash = name.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];

    return colors[hash.abs() % colors.length];
  }
}
