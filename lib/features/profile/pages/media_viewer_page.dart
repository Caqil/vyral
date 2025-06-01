import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vyral/core/utils/extensions.dart';

class MediaViewerPage extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const MediaViewerPage({
    super.key,
    required this.mediaUrls,
    this.initialIndex = 0,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} of ${widget.mediaUrls.length}'),
        actions: [
          IconButton(
            onPressed: _shareMedia,
            icon: const Icon(LucideIcons.share),
          ),
          IconButton(
            onPressed: _downloadMedia,
            icon: const Icon(LucideIcons.download),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemCount: widget.mediaUrls.length,
        itemBuilder: (context, index) {
          final mediaUrl = widget.mediaUrls[index];
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: mediaUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    LucideIcons.image,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.mediaUrls.length > 1
          ? Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.mediaUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _shareMedia() {
    // Share current media
  }

  void _downloadMedia() {
    // Download current media
  }
}
