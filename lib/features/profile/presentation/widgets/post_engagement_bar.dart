// lib/features/profile/presentation/widgets/post_engagement_bar.dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/post_entity.dart';

class PostEngagementBar extends StatefulWidget {
  final PostEntity post;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onBookmarkPressed;

  const PostEngagementBar({
    super.key,
    required this.post,
    this.onLikePressed,
    this.onCommentPressed,
    this.onSharePressed,
    this.onBookmarkPressed,
  });

  @override
  State<PostEngagementBar> createState() => _PostEngagementBarState();
}

class _PostEngagementBarState extends State<PostEngagementBar>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _likeRotationAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));

    _likeRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.border),
          bottom: BorderSide(color: colorScheme.border),
        ),
      ),
      child: Column(
        children: [
          // Engagement Stats
          if (widget.post.likesCount > 0 ||
              widget.post.commentsCount > 0 ||
              widget.post.sharesCount > 0)
            _buildEngagementStats(colorScheme, theme),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: widget.post.isLiked
                      ? LucideIcons.heart
                      : LucideIcons.heart,
                  label: 'Like',
                  count: widget.post.likesCount,
                  isActive: widget.post.isLiked,
                  activeColor: Colors.red,
                  onPressed: () {
                    if (widget.post.isLiked) {
                      _likeAnimationController.reverse();
                    } else {
                      _likeAnimationController.forward();
                    }
                    widget.onLikePressed?.call();
                  },
                  animation: _likeScaleAnimation,
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  icon: LucideIcons.messageCircle,
                  label: 'Comment',
                  count: widget.post.commentsCount,
                  onPressed: widget.onCommentPressed,
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  icon: LucideIcons.share,
                  label: 'Share',
                  count: widget.post.sharesCount,
                  onPressed: widget.onSharePressed,
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
              ShadButton.ghost(
                onPressed: widget.onBookmarkPressed,
                size: ShadButtonSize.sm,
                child: Icon(
                  widget.post.isBookmarked
                      ? LucideIcons.bookmark
                      : LucideIcons.bookmark,
                  color: widget.post.isBookmarked
                      ? colorScheme.primary
                      : colorScheme.mutedForeground,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementStats(
      ShadColorScheme colorScheme, ShadThemeData theme) {
    final hasLikes = widget.post.likesCount > 0;
    final hasComments = widget.post.commentsCount > 0;
    final hasShares = widget.post.sharesCount > 0;

    return Row(
      children: [
        if (hasLikes) ...[
          GestureDetector(
            onTap: () => _showLikesBottomSheet(),
            child: Row(
              children: [
                Icon(
                  LucideIcons.heart,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  Helpers.formatNumber(widget.post.likesCount),
                  style: theme.textTheme.small.copyWith(
                    color: colorScheme.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (hasLikes && (hasComments || hasShares))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '•',
              style: TextStyle(color: colorScheme.mutedForeground),
            ),
          ),
        if (hasComments) ...[
          GestureDetector(
            onTap: widget.onCommentPressed,
            child: Text(
              '${Helpers.formatNumber(widget.post.commentsCount)} comments',
              style: theme.textTheme.small.copyWith(
                color: colorScheme.mutedForeground,
              ),
            ),
          ),
        ],
        if (hasComments && hasShares)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '•',
              style: TextStyle(color: colorScheme.mutedForeground),
            ),
          ),
        if (hasShares) ...[
          Text(
            '${Helpers.formatNumber(widget.post.sharesCount)} shares',
            style: theme.textTheme.small.copyWith(
              color: colorScheme.mutedForeground,
            ),
          ),
        ],
        const Spacer(),
        Text(
          '${Helpers.formatNumber(widget.post.viewsCount)} views',
          style: theme.textTheme.small.copyWith(
            color: colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int count,
    bool isActive = false,
    Color? activeColor,
    VoidCallback? onPressed,
    Animation<double>? animation,
    required ShadColorScheme colorScheme,
    required ShadThemeData theme,
  }) {
    Widget iconWidget = Icon(
      icon,
      color: isActive
          ? (activeColor ?? colorScheme.primary)
          : colorScheme.mutedForeground,
      size: 20,
    );

    if (animation != null) {
      iconWidget = AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            child: iconWidget,
          );
        },
      );
    }

    return ShadButton.ghost(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              Helpers.formatNumber(count),
              style: theme.textTheme.small.copyWith(
                color: isActive
                    ? (activeColor ?? colorScheme.primary)
                    : colorScheme.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showLikesBottomSheet() {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: Text('${widget.post.likesCount} likes'),
        child: Container(
          height: 300,
          child: const Center(
            child: Text('Likes list would be shown here'),
          ),
        ),
      ),
    );
  }
}


