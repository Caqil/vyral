import 'package:flutter/material.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/post_entity.dart';
import 'post_card.dart';

class FeedList extends StatelessWidget {
  final ScrollController? scrollController;
  final List<PostEntity> posts;
  final bool isLoadingMore;
  final bool isRefreshing;
  final Function(String, bool)? onPostLike;
  final Function(String, bool)? onPostBookmark;
  final Function(String, String?)? onPostShare;
  final Function(String, String, String?)? onPostReport;
  final Function(String, int?)? onPostView;

  const FeedList({
    super.key,
    this.scrollController,
    required this.posts,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.onPostLike,
    this.onPostBookmark,
    this.onPostShare,
    this.onPostReport,
    this.onPostView,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        // Show loading indicator at the end when loading more
        if (index >= posts.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingWidget(message: 'Loading more posts...'),
          );
        }

        final post = posts[index];
        return PostCard(
          post: post,
          onLike: onPostLike != null
              ? () => onPostLike!(post.id, post.isLiked)
              : null,
          onBookmark: onPostBookmark != null
              ? () => onPostBookmark!(post.id, post.isBookmarked)
              : null,
          onShare: onPostShare != null
              ? (comment) => onPostShare!(post.id, comment)
              : null,
          onReport: onPostReport != null
              ? (reason, description) =>
                  onPostReport!(post.id, reason, description)
              : null,
          onView: onPostView != null
              ? (timeSpent) => onPostView!(post.id, timeSpent)
              : null,
        );
      },
    );
  }
}
