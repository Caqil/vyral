import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/app/app.dart';

class ProfileMediaGrid extends StatelessWidget {
  final List<dynamic>
      media; // Keep as dynamic to handle both MediaEntity and media URLs
  final bool isLoading;
  final bool hasMoreMedia;
  final Function(String) onMediaPressed;
  final VoidCallback onLoadMore;

  const ProfileMediaGrid({
    super.key,
    required this.media,
    required this.isLoading,
    required this.hasMoreMedia,
    required this.onMediaPressed,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    if (media.isEmpty && !isLoading) {
      return _buildEmptyState(colorScheme);
    }

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

        // Load More Section
        if (hasMoreMedia) ...[
          const SizedBox(height: 16),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ShadButton.outline(
                onPressed: onLoadMore,
                child: const Text('Load More Media'),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ShadColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            LucideIcons.image,
            size: 48,
            color: colorScheme.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'No Media Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photos and videos shared by this user will appear here.',
            style: TextStyle(
              color: colorScheme.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(dynamic media, ShadColorScheme colorScheme) {
    // Handle both MediaEntity and simple media URLs
    String mediaUrl;
    String mediaType = 'image';
    String? mediaId;

    if (media is Map<String, dynamic>) {
      mediaUrl = media['url'] ?? media['displayUrl'] ?? '';
      mediaType = media['type'] ?? 'image';
      mediaId = media['id'];
    } else if (media is String) {
      mediaUrl = media;
      mediaId = media;
    } else {
      // Handle MediaEntity or similar object
      mediaUrl = media.displayUrl ?? media.url ?? '';
      mediaType = media.type ?? 'image';
      mediaId = media.id;
    }

    return GestureDetector(
      onTap: () => onMediaPressed(mediaId ?? mediaUrl),
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
              CachedNetworkImage(
                imageUrl: mediaUrl,
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
                    _getMediaIcon(mediaType),
                    color: colorScheme.mutedForeground,
                  ),
                ),
              ),

              // Media Type Indicator
              if (mediaType.toLowerCase() == 'video')
                const Center(
                  child: Icon(
                    LucideIcons.play,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMediaIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return LucideIcons.video;
      case 'audio':
        return LucideIcons.music;
      case 'document':
        return LucideIcons.file;
      default:
        return LucideIcons.image;
    }
  }
}
