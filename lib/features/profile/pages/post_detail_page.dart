// lib/features/profile/presentation/pages/post_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../domain/entities/post_entity.dart';
import '../presentation/bloc/post_detail_bloc.dart';
import '../presentation/bloc/post_detail_event.dart';
import '../presentation/bloc/post_detail_state.dart';
import '../presentation/widgets/comment_section.dart';
import '../presentation/widgets/post_engagement_bar.dart';
import 'media_viewer_page.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late ScrollController _scrollController;
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    context.read<PostDetailBloc>().add(
          PostDetailLoadRequested(postId: widget.postId),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: CustomAppBar.simple(
        title: 'Post',
        automaticallyImplyLeading: true,
        actions: [
          ShadButton.ghost(
            onPressed: _showPostOptions,
            child:  Icon(LucideIcons.menu100),
          ),
        ],
      ),
      body: BlocBuilder<PostDetailBloc, PostDetailState>(
        builder: (context, state) {
          if (state.isLoading && state.post == null) {
            return const LoadingWidget(message: 'Loading post...');
          }

          if (state.hasError && state.post == null) {
            return CustomErrorWidget(
              title: 'Post Not Found',
              message: state.errorMessage ?? 'This post may have been deleted',
              onRetry: () => context.read<PostDetailBloc>().add(
                    PostDetailLoadRequested(postId: widget.postId),
                  ),
            );
          }

          if (state.post == null) {
            return const CustomErrorWidget(
              title: 'Post Not Found',
              message: 'This post does not exist or has been removed.',
            );
          }

          return Column(
            children: [
              // Post Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Post Header and Content
                      _buildPostContent(state.post!, state, colorScheme, theme),

                      // Engagement Bar
                      PostEngagementBar(
                        post: state.post!,
                        onLikePressed: () => _handleLikePressed(state.post!),
                        onCommentPressed: () => _focusCommentInput(),
                        onSharePressed: () => _handleSharePressed(state.post!),
                        onBookmarkPressed: () =>
                            _handleBookmarkPressed(state.post!),
                      ),

                      const SizedBox(height: 16),

                      // Comments Section
                      CommentSection(
                        postId: state.post!.id,
                        comments: state.comments,
                        isLoadingComments: state.isLoadingComments,
                        onCommentLikePressed: _handleCommentLike,
                        onReplyPressed: _handleReplyPressed,
                        onLoadMoreComments: _loadMoreComments,
                      ),

                      const SizedBox(height: 80), // Space for comment input
                    ],
                  ),
                ),
              ),

              // Comment Input
              _buildCommentInput(colorScheme, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostContent(
    PostEntity post,
    PostDetailState state,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Info
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/profile/${post.authorId}'),
                child: AvatarWidget(
                  imageUrl: state.author?.profilePicture,
                  name: state.author?.displayName ??
                      state.author?.username ??
                      'User',
                  size: 48,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/profile/${post.authorId}'),
                      child: Row(
                        children: [
                          Text(
                            state.author?.displayName ??
                                state.author?.username ??
                                'User',
                            style: theme.textTheme.list.copyWith(
                              color: colorScheme.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (state.author?.isVerified == true) ...[
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.badgeCheck,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '@${state.author?.username ?? 'user'}',
                      style: theme.textTheme.small.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                    Text(
                      post.createdAt.timeAgo,
                      style: theme.textTheme.small.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              ShadButton.ghost(
                onPressed: _showPostOptions,
                size: ShadButtonSize.sm,
                child:  Icon(LucideIcons.menu),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Post Content
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: theme.textTheme.small.copyWith(
                color: colorScheme.foreground,
              ),
            ),

          // Post Media
          if (post.hasMedia) ...[
            const SizedBox(height: 16),
            _buildPostMedia(post, colorScheme),
          ],

          // Post Location
          if (post.location != null) ...[
            const SizedBox(height: 12),
            Row(
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
          ],

          // Hashtags
          if (post.hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: post.hashtags.map((hashtag) {
                return GestureDetector(
                  onTap: () => context.go('/search?query=%23$hashtag'),
                  child: Text(
                    '#$hashtag',
                    style: theme.textTheme.list.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostMedia(PostEntity post, ShadColorScheme colorScheme) {
    if (post.mediaUrls.length == 1) {
      return _buildSingleMedia(post.mediaUrls.first, post, colorScheme);
    } else {
      return _buildMediaGrid(post.mediaUrls, post, colorScheme);
    }
  }

  Widget _buildSingleMedia(
      String mediaUrl, PostEntity post, ShadColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _openMediaViewer(post.mediaUrls, 0),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 400,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: post.isVideoPost
              ? _buildVideoPlayer(mediaUrl, colorScheme)
              : CachedNetworkImage(
                  imageUrl: mediaUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
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
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid(
      List<String> mediaUrls, PostEntity post, ShadColorScheme colorScheme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mediaUrls.length > 2 ? 2 : mediaUrls.length,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: mediaUrls.length > 4 ? 4 : mediaUrls.length,
      itemBuilder: (context, index) {
        final mediaUrl = mediaUrls[index];
        final isLastItem = index == 3 && mediaUrls.length > 4;

        return GestureDetector(
          onTap: () => _openMediaViewer(mediaUrls, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: mediaUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.muted,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: colorScheme.muted,
                      child: Icon(
                        LucideIcons.image,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  if (isLastItem)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          '+${mediaUrls.length - 4}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(String videoUrl, ShadColorScheme colorScheme) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video thumbnail or placeholder
          Container(
            width: double.infinity,
            height: 200,
            color: colorScheme.muted,
            child: Icon(
              LucideIcons.video,
              color: colorScheme.mutedForeground,
              size: 48,
            ),
          ),

          // Play button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.play,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ShadColorScheme colorScheme, ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.background,
        border: Border(
          top: BorderSide(color: colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: null, // Current user's avatar
            name: 'You',
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: colorScheme.border),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          ShadButton.ghost(
            onPressed: _submitComment,
            size: ShadButtonSize.sm,
            child: const Icon(LucideIcons.send),
          ),
        ],
      ),
    );
  }

  void _handleLikePressed(PostEntity post) {
    context.read<PostDetailBloc>().add(
          PostDetailLikeToggled(postId: post.id),
        );
  }

  void _handleSharePressed(PostEntity post) {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Share Post'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                // Copy post link
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.share2),
              title: const Text('Share via...'),
              onTap: () {
                Navigator.pop(context);
                // Share via system
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleBookmarkPressed(PostEntity post) {
    context.read<PostDetailBloc>().add(
          PostDetailBookmarkToggled(postId: post.id),
        );
  }

  void _handleCommentLike(String commentId) {
    context.read<PostDetailBloc>().add(
          PostDetailCommentLikeToggled(commentId: commentId),
        );
  }

  void _handleReplyPressed(String commentId) {
    // Focus comment input and set reply context
    _commentFocusNode.requestFocus();
  }

  void _focusCommentInput() {
    _commentFocusNode.requestFocus();
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      context.read<PostDetailBloc>().add(
            PostDetailCommentSubmitted(
              postId: widget.postId,
              content: content,
            ),
          );
      _commentController.clear();
    }
  }

  void _loadMoreComments() {
    context.read<PostDetailBloc>().add(
          PostDetailLoadMoreCommentsRequested(postId: widget.postId),
        );
  }

  void _openMediaViewer(List<String> mediaUrls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerPage(
          mediaUrls: mediaUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showPostOptions() {
    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Post Options'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.flag),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                // Report post
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.eyeOff),
              title: const Text('Hide Post'),
              onTap: () {
                Navigator.pop(context);
                // Hide post
              },
            ),
          ],
        ),
      ),
    );
  }
}
