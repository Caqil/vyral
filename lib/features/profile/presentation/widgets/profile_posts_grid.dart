// lib/features/profile/presentation/widgets/profile_posts_grid.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/media_entity.dart';
import '../../domain/entities/post_entity.dart';

class ProfilePostsGrid extends StatelessWidget {
  final List<PostEntity> posts;
  final bool isLoading;
  final Function(String) onPostPressed;
  final VoidCallback onLoadMore;

  const ProfilePostsGrid({
    super.key,
    required this.posts,
    required this.isLoading,
    required this.onPostPressed,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        // Posts Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostItem(post, colorScheme);
            },
          ),
        ),

        // Load More Button
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShadButton.outline(
              onPressed: onLoadMore,
              child: const Text('Load More Posts'),
            ),
          ),
      ],
    );
  }

  Widget _buildPostItem(PostEntity post, ShadColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => onPostPressed(post.id),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Post Image or Placeholder
              if (post.hasMedia && post.isImagePost)
                CachedNetworkImage(
                  imageUrl: post.mediaUrls.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: colorScheme.muted,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      _buildTextPostPreview(post, colorScheme),
                )
              else if (post.isVideoPost)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: colorScheme.muted,
                      child: const Icon(LucideIcons.play, size: 32),
                    ),
                    if (post.mediaUrls.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl:
                            '${post.mediaUrls.first}_thumbnail', // Assume thumbnail URL
                        fit: BoxFit.cover,
                      ),
                  ],
                )
              else
                _buildTextPostPreview(post, colorScheme),

              // Post Type Indicators
              Positioned(
                top: 8,
                right: 8,
                child: _buildPostTypeIndicator(post, colorScheme),
              ),

              // Engagement Stats
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: _buildEngagementStats(post, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextPostPreview(PostEntity post, ShadColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: colorScheme.muted,
      child: Center(
        child: Text(
          post.content,
          style: TextStyle(
            color: colorScheme.foreground,
            fontSize: 12,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPostTypeIndicator(PostEntity post, ShadColorScheme colorScheme) {
    IconData icon;
    if (post.isVideoPost) {
      icon = LucideIcons.video;
    } else if (post.isImagePost) {
      icon = LucideIcons.image;
    } else {
      icon = LucideIcons.type;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 12,
      ),
    );
  }

  Widget _buildEngagementStats(PostEntity post, ShadColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.heart,
            color: Colors.white,
            size: 10,
          ),
          const SizedBox(width: 2),
          Text(
            '${post.likesCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            LucideIcons.messageCircle,
            color: Colors.white,
            size: 10,
          ),
          const SizedBox(width: 2),
          Text(
            '${post.commentsCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// lib/features/profile/presentation/widgets/profile_media_grid.dart
class ProfileMediaGrid extends StatelessWidget {
  final List<MediaEntity> media;
  final bool isLoading;
  final Function(String) onMediaPressed;
  final VoidCallback onLoadMore;

  const ProfileMediaGrid({
    super.key,
    required this.media,
    required this.isLoading,
    required this.onMediaPressed,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        // Media Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: media.length,
            itemBuilder: (context, index) {
              final mediaItem = media[index];
              return _buildMediaItem(mediaItem, colorScheme);
            },
          ),
        ),

        // Load More Button
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShadButton.outline(
              onPressed: onLoadMore,
              child: const Text('Load More Media'),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaItem(MediaEntity media, ShadColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => onMediaPressed(media.id),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media Content
              if (media.isImage)
                CachedNetworkImage(
                  imageUrl: media.displayUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: colorScheme.muted,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: colorScheme.muted,
                    child: Icon(
                      LucideIcons.image,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                )
              else if (media.isVideo)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: colorScheme.muted,
                    ),
                    if (media.thumbnailUrl != null)
                      CachedNetworkImage(
                        imageUrl: media.thumbnailUrl!,
                        fit: BoxFit.cover,
                      ),
                    const Center(
                      child: Icon(
                        LucideIcons.play,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  color: colorScheme.muted,
                  child: Icon(
                    _getMediaIcon(media.type),
                    color: colorScheme.mutedForeground,
                    size: 24,
                  ),
                ),

              // Media Type Indicator
              Positioned(
                top: 8,
                right: 8,
                child: _buildMediaTypeIndicator(media, colorScheme),
              ),

              // Duration for videos
              if (media.isVideo && media.duration != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDuration(media.duration!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaTypeIndicator(
      MediaEntity media, ShadColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getMediaIcon(media.type),
        color: Colors.white,
        size: 12,
      ),
    );
  }

  IconData _getMediaIcon(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return LucideIcons.image;
      case 'video':
        return LucideIcons.video;
      case 'audio':
        return LucideIcons.music;
      case 'document':
        return LucideIcons.file;
      default:
        return LucideIcons.file;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
