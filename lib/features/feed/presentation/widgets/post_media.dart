import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/models/media_model.dart';

class PostMedia extends StatelessWidget {
  final List<MediaModel> media;
  final double? aspectRatio;
  final BorderRadius? borderRadius;

  const PostMedia({
    super.key,
    required this.media,
    this.aspectRatio,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: _buildMediaContent(),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (media.length == 1) {
      return _buildSingleMedia(media.first);
    } else {
      return _buildMultipleMedia();
    }
  }

  Widget _buildSingleMedia(MediaModel mediaItem) {
    switch (mediaItem.type) {
      case 'image':
        return _buildImage(mediaItem);
      case 'video':
        return _buildVideo(mediaItem);
      default:
        return _buildImage(mediaItem);
    }
  }

  Widget _buildImage(MediaModel mediaItem) {
    return AspectRatio(
      aspectRatio: aspectRatio ?? _calculateAspectRatio(mediaItem),
      child: CachedNetworkImage(
        imageUrl: mediaItem.url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.error_outline),
          ),
        ),
      ),
    );
  }

  Widget _buildVideo(MediaModel mediaItem) {
    return AspectRatio(
      aspectRatio: aspectRatio ?? _calculateAspectRatio(mediaItem),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: mediaItem.thumbnailUrl ?? mediaItem.url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error_outline),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.play_circle_fill,
              size: 64,
              color: Colors.white,
            ),
          ),
          if (mediaItem.duration != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(mediaItem.duration!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMultipleMedia() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: PageView.builder(
        itemCount: media.length,
        itemBuilder: (context, index) {
          final mediaItem = media[index];
          return Stack(
            children: [
              _buildSingleMedia(mediaItem),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${index + 1}/${media.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateAspectRatio(MediaModel mediaItem) {
    if (mediaItem.width != null && mediaItem.height != null) {
      return mediaItem.width! / mediaItem.height!;
    }
    return 16 / 9; // Default aspect ratio
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
