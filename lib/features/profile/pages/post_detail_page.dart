import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/widgets/loading_widget.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/post_detail_bloc.dart';
import '../bloc/post_detail_event.dart';
import '../bloc/post_detail_state.dart';
import '../data/models/comment_model.dart';
import '../domain/entities/post_entity.dart';
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

class _PostDetailPageState extends State<PostDetailPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Load post after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PostDetailBloc>().add(
              PostDetailLoadRequested(postId: widget.postId),
            );
      }
    });
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

    return Scaffold(
      appBar: CustomAppBar.simple(
        title: 'Post',
        automaticallyImplyLeading: true,
        actions: [
          ShadButton.ghost(
            onPressed: () {
              if (mounted) _showPostOptions();
            },
            child: const Icon(LucideIcons.menu),
          ),
        ],
      ),
      body: BlocConsumer<PostDetailBloc, PostDetailState>(
        listener: (context, state) {
          // Handle side effects if needed (e.g., show toast for errors)
        },
        builder: (context, state) {
          return _buildContent(state, colorScheme);
        },
      ),
    );
  }

  Widget _buildContent(PostDetailState state, ShadColorScheme colorScheme) {
    if (state.isLoading && state.post == null) {
      return const LoadingWidget(message: 'Loading post...');
    }

    if (state.hasError && state.post == null) {
      return CustomErrorWidget(
        title: 'Post Not Found',
        message: state.errorMessage ?? 'This post may have been deleted',
        onRetry: () {
          if (mounted) {
            context.read<PostDetailBloc>().add(
                  PostDetailLoadRequested(postId: widget.postId),
                );
          }
        },
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
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _PostContentWidget(
                  post: state.post!,
                  author: state.author,
                  onAuthorPressed: () {
                    if (mounted) _navigateToProfile(state.post!.authorId);
                  },
                  onOptionsPressed: () {
                    if (mounted) _showPostOptions();
                  },
                ),
                _PostEngagementWidget(
                  post: state.post!,
                  onLikePressed: () {
                    if (mounted) _handleLikePressed(state.post!);
                  },
                  onCommentPressed: () {
                    if (mounted) _focusCommentInput();
                  },
                  onSharePressed: () {
                    if (mounted) _handleSharePressed(state.post!);
                  },
                  onBookmarkPressed: () {
                    if (mounted) _handleBookmarkPressed(state.post!);
                  },
                ),
                const SizedBox(height: 16),
                _CommentsWidget(
                  postId: state.post!.id,
                  comments: state.comments,
                  isLoadingComments: state.isLoadingComments,
                  hasMoreComments: state.hasMoreComments,
                  onCommentLikePressed: (commentId) {
                    if (mounted) _handleCommentLike(commentId);
                  },
                  onReplyPressed: (commentId) {
                    if (mounted) _handleReplyPressed(commentId);
                  },
                  onLoadMoreComments: () {
                    if (mounted) _loadMoreComments();
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        _CommentInputWidget(
          controller: _commentController,
          focusNode: _commentFocusNode,
          onSubmit: () {
            if (mounted) _submitComment();
          },
        ),
      ],
    );
  }

  // Event handlers
  void _handleLikePressed(PostEntity post) async {
    if (!mounted) return;
    // Assuming like operation is async
    context.read<PostDetailBloc>().add(
          PostDetailLikeToggled(postId: post.id),
        );
  }

  void _handleSharePressed(PostEntity post) {
    if (!mounted) return;

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
                if (mounted) {
                  Navigator.pop(context);
                  // Implement copy link logic
                }
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.share2),
              title: const Text('Share via...'),
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                  // Implement share logic
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleBookmarkPressed(PostEntity post) async {
    if (!mounted) return;
    // Assuming bookmark operation is async
    context.read<PostDetailBloc>().add(
          PostDetailBookmarkToggled(postId: post.id),
        );
  }

  void _handleCommentLike(String commentId) async {
    if (!mounted) return;
    // Assuming comment like operation is async
    context.read<PostDetailBloc>().add(
          PostDetailCommentLikeToggled(commentId: commentId),
        );
  }

  void _handleReplyPressed(String commentId) {
    if (!mounted) return;
    _focusCommentInput();
  }

  void _focusCommentInput() {
    if (!mounted) return;
    _commentFocusNode.requestFocus();
  }

  void _submitComment() async {
    if (!mounted) return;

    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      // Assuming comment submission is async
      context.read<PostDetailBloc>().add(
            PostDetailCommentSubmitted(
              postId: widget.postId,
              content: content,
            ),
          );
      if (mounted) {
        _commentController.clear();
      }
    }
  }

  void _loadMoreComments() async {
    if (!mounted) return;
    // Assuming loading comments is async
    context.read<PostDetailBloc>().add(
          PostDetailLoadMoreCommentsRequested(postId: widget.postId),
        );
  }

  void _navigateToProfile(String userId) {
    if (!mounted) return;
    context.push('/profile/$userId');
  }

  void _showPostOptions() {
    if (!mounted) return;

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
                if (mounted) {
                  Navigator.pop(context);
                  // Implement report logic
                }
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.eyeOff),
              title: const Text('Hide Post'),
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                  // Implement hide logic
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostContentWidget extends StatelessWidget {
  final PostEntity post;
  final dynamic author;
  final VoidCallback onAuthorPressed;
  final VoidCallback onOptionsPressed;

  const _PostContentWidget({
    required this.post,
    required this.author,
    required this.onAuthorPressed,
    required this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onAuthorPressed,
                child: AvatarWidget(
                  imageUrl: author?.profilePicture,
                  name: author?.displayName ?? author?.username ?? 'User',
                  size: 48,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onAuthorPressed,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            author?.displayName ?? author?.username ?? 'User',
                            style: theme.textTheme.list.copyWith(
                              color: colorScheme.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (author?.isVerified == true) ...[
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.badgeCheck,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${author?.username ?? 'user'}',
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
              ),
              ShadButton.ghost(
                onPressed: onOptionsPressed,
                size: ShadButtonSize.sm,
                child: const Icon(LucideIcons.menu),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (post.content.isNotEmpty)
            Text(
              post.content,
              style: theme.textTheme.p.copyWith(
                color: colorScheme.foreground,
              ),
            ),
          if (post.hasMedia) ...[
            const SizedBox(height: 16),
            _PostMediaWidget(post: post),
          ],
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
          if (post.hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: post.hashtags.map((hashtag) {
                return GestureDetector(
                  onTap: () {
                    if (context.mounted) _navigateToHashtag(context, hashtag);
                  },
                  child: Text(
                    '#$hashtag',
                    style: theme.textTheme.p.copyWith(
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

  void _navigateToHashtag(BuildContext context, String hashtag) {
    if (context.mounted) {
      context.push('/search?query=%23$hashtag');
    }
  }
}

class _PostMediaWidget extends StatelessWidget {
  final PostEntity post;

  const _PostMediaWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    if (post.mediaUrls.length == 1) {
      return _buildSingleMedia(context, post.mediaUrls.first, colorScheme);
    } else {
      return _buildMediaGrid(context, post.mediaUrls, colorScheme);
    }
  }

  Widget _buildSingleMedia(
      BuildContext context, String mediaUrl, ShadColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        if (context.mounted) _openMediaViewer(context, post.mediaUrls, 0);
      },
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
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

  Widget _buildMediaGrid(BuildContext context, List<String> mediaUrls,
      ShadColorScheme colorScheme) {
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
          onTap: () {
            if (context.mounted) _openMediaViewer(context, mediaUrls, index);
          },
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

  void _openMediaViewer(
      BuildContext context, List<String> mediaUrls, int initialIndex) {
    if (context.mounted) {
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
  }
}

class _PostEngagementWidget extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onBookmarkPressed;

  const _PostEngagementWidget({
    required this.post,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onSharePressed,
    required this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PostEngagementBar(
      post: post,
      onLikePressed: onLikePressed,
      onCommentPressed: onCommentPressed,
      onSharePressed: onSharePressed,
      onBookmarkPressed: onBookmarkPressed,
    );
  }
}

class _CommentsWidget extends StatelessWidget {
  final String postId;
  final List<CommentModel> comments;
  final bool isLoadingComments;
  final bool hasMoreComments;
  final Function(String) onCommentLikePressed;
  final Function(String) onReplyPressed;
  final VoidCallback onLoadMoreComments;

  const _CommentsWidget({
    required this.postId,
    required this.comments,
    required this.isLoadingComments,
    required this.hasMoreComments,
    required this.onCommentLikePressed,
    required this.onReplyPressed,
    required this.onLoadMoreComments,
  });

  @override
  Widget build(BuildContext context) {
    return CommentSection(
      postId: postId,
      comments: comments,
      isLoadingComments: isLoadingComments,
      onCommentLikePressed: onCommentLikePressed,
      onReplyPressed: onReplyPressed,
      onLoadMoreComments: onLoadMoreComments,
    );
  }
}

class _CommentInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  const _CommentInputWidget({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

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
              controller: controller,
              focusNode: focusNode,
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
              onSubmitted: (_) {
                if (context.mounted) onSubmit();
              },
            ),
          ),
          const SizedBox(width: 8),
          ShadButton.ghost(
            onPressed: () {
              if (context.mounted) onSubmit();
            },
            size: ShadButtonSize.sm,
            child: const Icon(LucideIcons.send),
          ),
        ],
      ),
    );
  }
}
