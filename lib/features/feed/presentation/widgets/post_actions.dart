// lib/features/feed/presentation/widgets/post_actions.dart
import 'package:flutter/material.dart';
import '../../domain/entities/post_entity.dart';

class PostActions extends StatelessWidget {
  final PostEntity post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onMore;

  const PostActions({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Like button
          if (post.likesEnabled)
            _ActionButton(
              icon: post.isLiked ? Icons.favorite : Icons.favorite_outline,
              iconColor: post.isLiked ? Colors.red : null,
              label: post.stats.likesCount > 0 ? '${post.stats.likesCount}' : 'Like',
              onTap: onLike,
            ),

          // Comment button
          if (post.commentsEnabled)
            _ActionButton(
              icon: Icons.comment_outlined,
              label: post.stats.commentsCount > 0 ? '${post.stats.commentsCount}' : 'Comment',
              onTap: onComment,
            ),

          // Share button
          if (post.sharesEnabled)
            _ActionButton(
              icon: Icons.share_outlined,
              label: post.stats.sharesCount > 0 ? '${post.stats.sharesCount}' : 'Share',
              onTap: onShare,
            ),

          // Bookmark button
          _ActionButton(
            icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
            iconColor: post.isBookmarked ? colorScheme.primary : null,
            label: 'Save',
            onTap: onBookmark,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: iconColor ?? colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
