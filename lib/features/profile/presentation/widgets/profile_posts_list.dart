// lib/features/profile/presentation/widgets/profile_posts_list.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../domain/entities/post_entity.dart';

class ProfilePostsList extends StatelessWidget {
  final List<PostEntity> posts;
  final bool isLoading;
  final Function(String) onPostPressed;
  final VoidCallback onLoadMore;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatar;

  const ProfilePostsList({
    super.key,
    required this.posts,
    required this.isLoading,
    required this.onPostPressed,
    required this.onLoadMore,
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        // Posts List
        if (posts.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(post, colorScheme, theme);
            },
          ),

        // Load More Section
        const SizedBox(height: 24),
        if (isLoading)
          Container(
            padding: const EdgeInsets.all(24),
            child: const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading more posts...'),
              ],
            ),
          )
        else if (posts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShadButton.outline(
              onPressed: onLoadMore,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.refreshCw, size: 16),
                  SizedBox(width: 8),
                  Text('Load More Posts'),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPostCard(
      PostEntity post, ShadColorScheme colorScheme, ShadThemeData theme) {
    return GestureDetector(
      onTap: () => onPostPressed(post.id),
      child: ShadCard(
        padding: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            _buildPostHeader(post, colorScheme, theme),

            // Post Content
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPostContent(post, colorScheme, theme),
            ],

            // Post Media
            if (post.hasMedia) ...[
              const SizedBox(height: 12),
              _buildPostMedia(post, colorScheme),
            ],

            // Post Location
            if (post.location != null) ...[
              const SizedBox(height: 8),
              _buildLocationTag(post, colorScheme, theme),
            ],

            // Hashtags
            if (post.hashtags.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildHashtags(post, colorScheme, theme),
            ],

            const SizedBox(height: 12),

            // Engagement Stats
            _buildEngagementStats(post, colorScheme, theme),

            const SizedBox(height: 12),

            // Action Buttons
            _buildActionButtons(post, colorScheme, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(
      PostEntity post, ShadColorScheme colorScheme, ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Author Avatar
          AvatarWidget(
            imageUrl: authorAvatar,
            name: authorName ?? authorUsername ?? 'User',
            size: 40,
          ),

          const SizedBox(width: 12),

          // Author Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (authorName != null)
                      Text(
                        authorName!,
                        style: theme.textTheme.p.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.foreground,
                        ),
                      ),
                    if (authorUsername != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '@$authorUsername',
                        style: theme.textTheme.small.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  post.createdAt.timeAgo,
                  style: theme.textTheme.small.copyWith(
                    color: colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Post Menu
          ShadButton.ghost(
            onPressed: () => _showPostMenu(post),
            size: ShadButtonSize.sm,
            child: Icon(
              LucideIcons.menu,
              size: 16,
              color: colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(
      PostEntity post, ShadColorScheme colorScheme, ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        post.content,
        style: theme.textTheme.p.copyWith(
          color: colorScheme.foreground,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildPostMedia(PostEntity post, ShadColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildMediaContent(post, colorScheme),
      ),
    );
  }

  Widget _buildMediaContent(PostEntity post, ShadColorScheme colorScheme) {
    if (post.mediaUrls.length == 1) {
      return _buildSingleMedia(post.mediaUrls.first, post, colorScheme);
    } else if (post.mediaUrls.length == 2) {
      return _buildTwoMediaLayout(post.mediaUrls, post, colorScheme);
    } else if (post.mediaUrls.length <= 4) {
      return _buildMultipleMediaLayout(post.mediaUrls, post, colorScheme);
    } else {
      return _buildMoreThanFourMediaLayout(post.mediaUrls, post, colorScheme);
    }
  }

  Widget _buildSingleMedia(
      String mediaUrl, PostEntity post, ShadColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 400,
        minHeight: 200,
      ),
      child: Stack(
        children: [
          if (post.isVideoPost)
            _buildVideoPreview(mediaUrl, colorScheme)
          else
            CachedNetworkImage(
              imageUrl: mediaUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: colorScheme.muted,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: colorScheme.muted,
                child: Icon(
                  LucideIcons.image,
                  color: colorScheme.mutedForeground,
                  size: 48,
                ),
              ),
            ),

          // Media Type Indicator
          if (post.isVideoPost)
            const Positioned(
              top: 12,
              right: 12,
              child: _MediaTypeChip(icon: LucideIcons.video, label: 'Video'),
            ),
        ],
      ),
    );
  }

  Widget _buildTwoMediaLayout(
      List<String> mediaUrls, PostEntity post, ShadColorScheme colorScheme) {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: mediaUrls[0],
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colorScheme.muted,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.muted,
                child:
                    Icon(LucideIcons.image, color: colorScheme.mutedForeground),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: CachedNetworkImage(
              imageUrl: mediaUrls[1],
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colorScheme.muted,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.muted,
                child:
                    Icon(LucideIcons.image, color: colorScheme.mutedForeground),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleMediaLayout(
      List<String> mediaUrls, PostEntity post, ShadColorScheme colorScheme) {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: mediaUrls[0],
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colorScheme.muted,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.muted,
                child:
                    Icon(LucideIcons.image, color: colorScheme.mutedForeground),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                for (int i = 1; i < mediaUrls.length && i < 3; i++) ...[
                  if (i > 1) const SizedBox(width: 2),
                  Expanded(
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: mediaUrls[i],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.muted,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.muted,
                            child: Icon(LucideIcons.image,
                                color: colorScheme.mutedForeground),
                          ),
                        ),
                        if (i == 2 && mediaUrls.length > 3)
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Text(
                                '+${mediaUrls.length - 3}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreThanFourMediaLayout(
      List<String> mediaUrls, PostEntity post, ShadColorScheme colorScheme) {
    return _buildMultipleMediaLayout(
        mediaUrls.take(4).toList(), post, colorScheme);
  }

  Widget _buildVideoPreview(String videoUrl, ShadColorScheme colorScheme) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Video thumbnail placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: colorScheme.muted,
          ),

          // Play button
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.play,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTag(
      PostEntity post, ShadColorScheme colorScheme, ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            LucideIcons.mapPin,
            size: 14,
            color: colorScheme.mutedForeground,
          ),
          const SizedBox(width: 4),
          Text(
            post.location!,
            style: theme.textTheme.small.copyWith(
              color: colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtags(
      PostEntity post, ShadColorScheme colorScheme, ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: post.hashtags.map((hashtag) {
          return GestureDetector(
            onTap: () {
              // Navigate to hashtag page
            },
            child: Text(
              '#$hashtag',
              style: theme.textTheme.small.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEngagementStats(
      PostEntity post, ShadColorScheme colorScheme, ShadThemeData theme) {
    if (post.likesCount == 0 &&
        post.commentsCount == 0 &&
        post.sharesCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (post.likesCount > 0) ...[
            Icon(
              LucideIcons.heart,
              size: 14,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              '${post.likesCount}',
              style: theme.textTheme.small.copyWith(
                color: colorScheme.foreground,
              ),
            ),
          ],
          if (post.likesCount > 0 &&
              (post.commentsCount > 0 || post.sharesCount > 0))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.mutedForeground,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (post.commentsCount > 0) ...[
            Text(
              '${post.commentsCount} comments',
              style: theme.textTheme.small.copyWith(
                color: colorScheme.mutedForeground,
              ),
            ),
          ],
          if (post.commentsCount > 0 && post.sharesCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.mutedForeground,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (post.sharesCount > 0) ...[
            Text(
              '${post.sharesCount} shares',
              style: theme.textTheme.small.copyWith(
                color: colorScheme.mutedForeground,
              ),
            ),
          ],
          const Spacer(),
          if (post.viewsCount > 0)
            Text(
              '${post.viewsCount} views',
              style: theme.textTheme.small.copyWith(
                color: colorScheme.mutedForeground,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      PostEntity post, ShadColorScheme colorScheme, ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          // Like Button
          Expanded(
            child: ShadButton.ghost(
              onPressed: () => _handleLike(post),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    post.isLiked ? LucideIcons.heart : LucideIcons.heart,
                    size: 18,
                    color:
                        post.isLiked ? Colors.red : colorScheme.mutedForeground,
                  ),
                  if (post.likesCount > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '${post.likesCount}',
                      style: theme.textTheme.small.copyWith(
                        color: post.isLiked
                            ? Colors.red
                            : colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Comment Button
          Expanded(
            child: ShadButton.ghost(
              onPressed: () => _handleComment(post),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.messageCircle,
                    size: 18,
                    color: colorScheme.mutedForeground,
                  ),
                  if (post.commentsCount > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentsCount}',
                      style: theme.textTheme.small.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Share Button
          Expanded(
            child: ShadButton.ghost(
              onPressed: () => _handleShare(post),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.share,
                    size: 18,
                    color: colorScheme.mutedForeground,
                  ),
                  if (post.sharesCount > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '${post.sharesCount}',
                      style: theme.textTheme.small.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bookmark Button
          ShadButton.ghost(
            onPressed: () => _handleBookmark(post),
            child: Icon(
              post.isBookmarked ? LucideIcons.bookmark : LucideIcons.bookmark,
              size: 18,
              color: post.isBookmarked
                  ? colorScheme.primary
                  : colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  void _showPostMenu(PostEntity post) {
    // Show post options menu
  }

  void _handleLike(PostEntity post) {
    // Handle like action
  }

  void _handleComment(PostEntity post) {
    // Handle comment action
  }

  void _handleShare(PostEntity post) {
    // Handle share action
  }

  void _handleBookmark(PostEntity post) {
    // Handle bookmark action
  }
}

class _MediaTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MediaTypeChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
