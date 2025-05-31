import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// shadcn/ui Button component for the social media app
class ShadcnButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ShadButtonVariant variant;
  final ShadButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? child;
  final double? width;
  final double? height;

  const ShadcnButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ShadButtonVariant.primary,
    this.size = ShadButtonSize.regular,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.width,
    this.height,
  });

  // Convenience constructors for different variants
  const ShadcnButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ShadButtonSize.regular,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.width,
    this.height,
  }) : variant = ShadButtonVariant.primary;

  const ShadcnButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ShadButtonSize.regular,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.width,
    this.height,
  }) : variant = ShadButtonVariant.secondary;

  const ShadcnButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ShadButtonSize.regular,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.width,
    this.height,
  }) : variant = ShadButtonVariant.outline;

  const ShadcnButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ShadButtonSize.regular,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.width,
    this.height,
  }) : variant = ShadButtonVariant.ghost;

  const ShadcnButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ShadButtonSize.regular,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.width,
    this.height,
  }) : variant = ShadButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = child ?? _buildButtonContent();

    if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    Widget button = ShadButton.raw(
      onPressed: isLoading ? null : onPressed,
      variant: variant,
      size: size,
      child: buttonChild,
    );

    if (isFullWidth) {
      button = SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: button,
      );
    } else if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }

  Color _getLoadingColor(BuildContext context) {
    final theme = ShadTheme.of(context);
    switch (variant) {
      case ShadButtonVariant.primary:
        return theme.colorScheme.primaryForeground;
      case ShadButtonVariant.secondary:
        return theme.colorScheme.secondaryForeground;
      case ShadButtonVariant.outline:
      case ShadButtonVariant.ghost:
        return theme.colorScheme.foreground;
      case ShadButtonVariant.destructive:
        return theme.colorScheme.destructiveForeground;
      case ShadButtonVariant.link:
        throw UnimplementedError();
    }
  }
}

/// Social media specific button variants
class SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isFollowing;
  final bool isLoading;
  final String? customText;

  const SocialButton.follow({
    super.key,
    this.onPressed,
    this.isFollowing = false,
    this.isLoading = false,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    String text = customText ?? (isFollowing ? 'Following' : 'Follow');
    ShadButtonVariant variant =
        isFollowing ? ShadButtonVariant.secondary : ShadButtonVariant.primary;

    return ShadcnButton(
      text: text,
      onPressed: onPressed,
      variant: variant,
      size: ShadButtonSize.sm,
      isLoading: isLoading,
      icon: isFollowing ? LucideIcons.userCheck : LucideIcons.userPlus,
    );
  }
}

class LikeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLiked;
  final int? likeCount;
  final bool showCount;

  const LikeButton({
    super.key,
    this.onPressed,
    this.isLiked = false,
    this.likeCount,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadButton.ghost(
      onPressed: onPressed,
      size: ShadButtonSize.sm,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked ? LucideIcons.heart : LucideIcons.heart,
            size: 16,
            color: isLiked
                ? const Color(0xFFEF4444) // Like color
                : theme.colorScheme.mutedForeground,
          ),
          if (showCount && likeCount != null && likeCount! > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(likeCount!),
              style: TextStyle(
                color: theme.colorScheme.mutedForeground,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class ShareButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final int? shareCount;
  final bool showCount;

  const ShareButton({
    super.key,
    this.onPressed,
    this.shareCount,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadButton.ghost(
      onPressed: onPressed,
      size: ShadButtonSize.sm,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.share,
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
          if (showCount && shareCount != null && shareCount! > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(shareCount!),
              style: TextStyle(
                color: theme.colorScheme.mutedForeground,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class CommentButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final int? commentCount;
  final bool showCount;

  const CommentButton({
    super.key,
    this.onPressed,
    this.commentCount,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadButton.ghost(
      onPressed: onPressed,
      size: ShadButtonSize.sm,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.messageCircle,
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
          if (showCount && commentCount != null && commentCount! > 0) ...[
            const SizedBox(width: 4),
            Text(
              _formatCount(commentCount!),
              style: TextStyle(
                color: theme.colorScheme.mutedForeground,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
