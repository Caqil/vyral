import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';
import 'package:vyral/core/widgets/avatar_widget.dart';

import '../../data/models/comment_model.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onLikePressed;
  final VoidCallback onReplyPressed;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onLikePressed,
    required this.onReplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarWidget(
            imageUrl: null, // Comment author's avatar
            name: 'User',
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment Header
                Row(
                  children: [
                    Text(
                      'Username', // Comment author name
                      style: theme.textTheme.small.copyWith(
                        color: colorScheme.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.createdAt.timeAgo,
                      style: theme.textTheme.small.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Comment Content
                Text(
                  comment.content,
                  style: theme.textTheme.small.copyWith(
                    color: colorScheme.foreground,
                  ),
                ),

                const SizedBox(height: 8),

                // Comment Actions
                Row(
                  children: [
                    ShadButton.ghost(
                      onPressed: onLikePressed,
                      size: ShadButtonSize.sm,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked
                                ? LucideIcons.heart
                                : LucideIcons.heart,
                            size: 16,
                            color: comment.isLiked
                                ? Colors.red
                                : colorScheme.mutedForeground,
                          ),
                          if (comment.likesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likesCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ShadButton.ghost(
                      onPressed: onReplyPressed,
                      size: ShadButtonSize.sm,
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                    if (comment.repliesCount > 0) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showReplies(context, comment),
                        child: Text(
                          'View ${comment.repliesCount} replies',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReplies(BuildContext context, CommentModel comment) {
    // Show replies in a bottom sheet or navigate to replies page
  }
}
