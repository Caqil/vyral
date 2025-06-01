// lib/features/profile/presentation/widgets/profile_content_tabs.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/features/profile/presentation/widgets/profile_media_grid.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/media_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import 'profile_about_section.dart';
import 'profile_posts_list.dart';

class ProfileContentTabs extends StatefulWidget {
  final UserEntity user;
  final List<PostEntity> posts;
  final List<MediaEntity> media;
  final bool isLoadingPosts;
  final bool isLoadingMedia;
  final bool isOwnProfile; // Add this parameter
  final String? currentUserId; // Add this parameter
  final Function(String) onPostPressed;
  final VoidCallback onLoadMorePosts;
  final VoidCallback onLoadMoreMedia;
  final VoidCallback? onRefreshPosts; // Add refresh callback

  const ProfileContentTabs({
    super.key,
    required this.user,
    required this.posts,
    required this.media,
    required this.isLoadingPosts,
    required this.isLoadingMedia,
    required this.isOwnProfile,
    this.currentUserId,
    required this.onPostPressed,
    required this.onLoadMorePosts,
    required this.onLoadMoreMedia,
    this.onRefreshPosts,
  });

  @override
  State<ProfileContentTabs> createState() => _ProfileContentTabsState();
}

class _ProfileContentTabsState extends State<ProfileContentTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        // Custom Tab Bar
        _buildTabBar(colorScheme, theme),

        const SizedBox(height: 16),

        // Tab Content
        _buildTabContent(colorScheme, theme),
      ],
    );
  }

  Widget _buildTabBar(ShadColorScheme colorScheme, ShadThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.muted.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: colorScheme.primaryForeground,
        unselectedLabelColor: colorScheme.mutedForeground,
        labelStyle: theme.textTheme.small?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.small,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.grid3x3, size: 16),
                const SizedBox(width: 8),
                Text('Posts (${widget.posts.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.image, size: 16),
                const SizedBox(width: 8),
                Text('Media (${widget.media.length})'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.user, size: 16),
                SizedBox(width: 8),
                Text('About'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ShadColorScheme colorScheme, ShadThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: IndexedStack(
        key: ValueKey(_currentIndex),
        index: _currentIndex,
        children: [
          // Posts Tab
          _buildPostsTab(colorScheme, theme),

          // Media Tab
          _buildMediaTab(colorScheme, theme),

          // About Tab
          _buildAboutTab(colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildPostsTab(ShadColorScheme colorScheme, ShadThemeData theme) {
    // Check if we're still loading posts
    if (widget.isLoadingPosts && widget.posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: LoadingWidget(message: 'Loading posts...'),
      );
    }

    // Check ProfileBloc state for errors
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        // If there's an error with posts, show error widget
        if (state.hasError && widget.posts.isEmpty && !widget.isLoadingPosts) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: CustomErrorWidget(
              title: 'Failed to Load Posts',
              message: state.errorMessage ?? 'Could not load posts',
              onRetry: widget.onRefreshPosts,
            ),
          );
        }

        // If no posts and not loading, show empty state
        if (widget.posts.isEmpty && !widget.isLoadingPosts) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: EmptyStateWidget(
              title: 'No Posts Yet',
              message: widget.isOwnProfile
                  ? 'Share your first post to get started!'
                  : '${widget.user.displayName ?? widget.user.username} hasn\'t posted anything yet.',
              icon: LucideIcons.fileText,
              actionText: widget.isOwnProfile ? 'Create Post' : null,
              onAction: widget.isOwnProfile
                  ? () {
                      // Navigate to create post
                    }
                  : null,
            ),
          );
        }

        // Show posts grid
        return ProfilePostsList(
          posts: widget.posts,
          isLoading: widget.isLoadingPosts,
          onPostPressed: widget.onPostPressed,
          onLoadMore: widget.onLoadMorePosts,
        );
      },
    );
  }

  Widget _buildMediaTab(ShadColorScheme colorScheme, ShadThemeData theme) {
    if (widget.isLoadingMedia && widget.media.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: LoadingWidget(message: 'Loading media...'),
      );
    }

    if (widget.media.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: EmptyStateWidget(
          title: 'No Media',
          message: widget.isOwnProfile
              ? 'Share photos and videos to see them here.'
              : '${widget.user.displayName ?? widget.user.username} hasn\'t shared any media yet.',
          icon: LucideIcons.image,
        ),
      );
    }

    return ProfileMediaGrid(
      media: widget.media,
      isLoading: widget.isLoadingMedia,
      onMediaPressed: (mediaId) {
        // Handle media press
      },
      onLoadMore: widget.onLoadMoreMedia,
      hasMoreMedia: true,
    );
  }

  Widget _buildAboutTab(ShadColorScheme colorScheme, ShadThemeData theme) {
    return ProfileAboutSection(
      user: widget.user,
    );
  }
}
