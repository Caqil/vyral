import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';

import '../../data/models/comment_model.dart';
import 'comment_item.dart';

class CommentSection extends StatelessWidget {
  final String postId;
  final List<CommentModel> comments;
  final bool isLoadingComments;
  final Function(String) onCommentLikePressed;
  final Function(String) onReplyPressed;
  final VoidCallback onLoadMoreComments;

  const CommentSection({
    super.key,
    required this.postId,
    required this.comments,
    required this.isLoadingComments,
    required this.onCommentLikePressed,
    required this.onReplyPressed,
    required this.onLoadMoreComments,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.shadTheme;
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Comments',
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.colorScheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (comments.isEmpty && !isLoadingComments)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    LucideIcons.messageCircle,
                    size: 48,
                    color: colorScheme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No comments yet',
                    style: theme.textTheme.large.copyWith(
                      color: colorScheme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to comment!',
                    style: theme.textTheme.h4.copyWith(
                      color: colorScheme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ...comments.map(
          (comment) => CommentItem(
            comment: comment,
            onLikePressed: () => onCommentLikePressed(comment.id),
            onReplyPressed: () => onReplyPressed(comment.id),
          ),
        ),
        if (isLoadingComments)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (comments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShadButton.outline(
              onPressed: onLoadMoreComments,
              child: const Text('Load More Comments'),
            ),
          ),
      ],
    );
  }
}
