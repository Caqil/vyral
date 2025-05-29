import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/media_model.dart';
import '../../domain/entities/post_entity.dart';
import 'post_actions.dart';
import 'post_media.dart';
import 'post_content.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final Function(String?)? onShare;
  final Function(String, String?)? onReport;
  final Function(int?)? onView;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onBookmark,
    this.onShare,
    this.onReport,
    this.onView,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  DateTime? _viewStartTime;
  bool _hasRecordedView = false;

  @override
  void initState() {
    super.initState();
    _viewStartTime = DateTime.now();

    // Record view after a short delay to ensure user actually saw the post
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hasRecordedView) {
        _recordView();
      }
    });
  }

  @override
  void dispose() {
    _recordView();
    super.dispose();
  }

  void _recordView() {
    if (_hasRecordedView || widget.onView == null || _viewStartTime == null)
      return;

    final timeSpent = DateTime.now().difference(_viewStartTime!).inSeconds;
    if (timeSpent > 1) {
      // Only record if viewed for more than 1 second
      widget.onView!(timeSpent);
      _hasRecordedView = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          _buildPostHeader(context),

          // Post content
          if (widget.post.content.isNotEmpty)
            PostContent(
              content: widget.post.content,
              hashtags: widget.post.hashtags,
              mentions: widget.post.mentions,
              maxLines: 6,
            ),

          // Post media
          if (widget.post.hasMedia) PostMedia(media: widget.post.media),

          // Post stats
          if (widget.post.stats.totalInteractions > 0) _buildPostStats(context),

          // Post actions
          PostActions(
            post: widget.post,
            onLike: widget.onLike,
            onComment: () => _handleComment(context),
            onShare: () => _handleShare(context),
            onBookmark: widget.onBookmark,
            onMore: () => _handleMore(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: post.author.profilePicture,
            name: post.author.fullName,
            size: 40,
            onTap: () => _handleUserTap(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.author.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (post.author.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                Text(
                  '@${post.author.username} • ${post.timeAgo}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _handleMore(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPostStats(BuildContext context) {
    final theme = Theme.of(context);
    final stats = widget.post.stats;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (stats.likesCount > 0) ...[
            Icon(
              Icons.favorite,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${stats.likesCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (stats.commentsCount > 0) ...[
            Icon(
              Icons.comment,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${stats.commentsCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (stats.sharesCount > 0) ...[
            Icon(
              Icons.share,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${stats.sharesCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const Spacer(),
          if (stats.viewsCount > 0)
            Text(
              '${stats.viewsCount} views',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  void _handleUserTap(BuildContext context) {
    // Navigate to user profile
  }

  void _handleComment(BuildContext context) {
    // Navigate to post detail/comments
  }

  void _handleShare(BuildContext context) {
    if (widget.onShare != null) {
      _showShareDialog(context);
    }
  }

  void _handleMore(BuildContext context) {
    _showMoreOptions(context);
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Post'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Add a comment (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onShare?.call(null); // TODO: Get comment from dialog
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title:
                Text(widget.post.isBookmarked ? 'Remove Bookmark' : 'Bookmark'),
            onTap: () {
              Navigator.pop(context);
              widget.onBookmark?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: const Text('Report'),
            onTap: () {
              Navigator.pop(context);
              _showReportDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Block User'),
            onTap: () {
              Navigator.pop(context);
              // Handle block user
            },
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    String selectedReason = 'spam';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedReason,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'spam', child: Text('Spam')),
                DropdownMenuItem(
                    value: 'harassment', child: Text('Harassment')),
                DropdownMenuItem(
                    value: 'inappropriate',
                    child: Text('Inappropriate Content')),
                DropdownMenuItem(
                    value: 'misinformation', child: Text('Misinformation')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => selectedReason = value ?? 'spam',
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Additional details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onReport
                  ?.call(selectedReason, null); // TODO: Get description
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
