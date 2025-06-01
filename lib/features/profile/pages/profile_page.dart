import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../presentation/bloc/profile_bloc.dart';
import '../presentation/bloc/profile_event.dart';
import '../presentation/bloc/profile_state.dart';
import '../presentation/widgets/profile_action_buttons.dart';
import '../presentation/widgets/profile_content_tabs.dart';
import '../presentation/widgets/profile_header.dart';
import '../presentation/widgets/profile_highlights.dart';
import '../presentation/widgets/profile_stats.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String? username;

  const ProfilePage({
    super.key,
    required this.userId,
    this.username,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_onScroll);

    // Load profile data
    context.read<ProfileBloc>().add(
          ProfileLoadRequested(userId: widget.userId),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const double collapsedHeight = 120.0;
    final double offset = _scrollController.offset;
    final bool shouldCollapse = offset > collapsedHeight;

    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = shouldCollapse);
      if (shouldCollapse) {
        _headerAnimationController.forward();
      } else {
        _headerAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
            body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Animated App Bar
              SliverAppBar(
                expandedHeight: 0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: colorScheme.background.withOpacity(0.8),
                flexibleSpace: AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.background.withOpacity(
                          0.8 + (0.2 * _headerAnimation.value),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: colorScheme.border.withOpacity(
                              _headerAnimation.value,
                            ),
                            width: 1,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              ShadButton.ghost(
                                onPressed: () => context.pop(),
                                child: Icon(
                                  LucideIcons.arrowLeft,
                                  color: colorScheme.foreground,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AnimatedOpacity(
                                  opacity: _headerAnimation.value,
                                  duration: const Duration(milliseconds: 200),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.user?.displayName ??
                                            state.user?.username ??
                                            'Loading...',
                                        style: theme.textTheme.h4.copyWith(
                                          color: colorScheme.foreground,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (state.user?.username != null)
                                        Text(
                                          '@${state.user!.username}',
                                          style: theme.textTheme.muted.copyWith(
                                            color: colorScheme.mutedForeground,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              _buildHeaderActions(state),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: _buildProfileContent(state, colorScheme, theme),
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildHeaderActions(ProfileState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadButton.ghost(
          onPressed: () => _showShareProfile(state.user),
          child: const Icon(LucideIcons.share),
        ),
        const SizedBox(width: 8),
        ShadButton.ghost(
          onPressed: () => _showProfileOptions(state.user),
          child: Icon(LucideIcons.menu),
        ),
      ],
    );
  }

  Widget _buildProfileContent(
    ProfileState state,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    if (state.isLoading && state.user == null) {
      return const SizedBox(
        height: 400,
        child: LoadingWidget(message: 'Loading profile...'),
      );
    }

    if (state.hasError && state.user == null) {
      print(state.errorMessage);
      return SizedBox(
        height: 400,
        child: CustomErrorWidget(
          title: 'Profile Not Found',
          message: state.errorMessage ?? 'Failed to load profile',
          onRetry: () => context.read<ProfileBloc>().add(
                ProfileLoadRequested(userId: widget.userId),
              ),
        ),
      );
    }

    if (state.user == null) {
      return const SizedBox(
        height: 400,
        child: CustomErrorWidget(
          title: 'Profile Not Found',
          message: 'This profile does not exist or has been removed.',
        ),
      );
    }

    return Column(
      children: [
        // Profile Header
        ProfileHeader(
          user: state.user!,
          coverImageUrl: state.user!.coverPicture,
          isOwnProfile: state.isOwnProfile,
        ),

        const SizedBox(height: 16),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ProfileActionButtons(
            user: state.user!,
            isOwnProfile: state.isOwnProfile,
            followStatus: state.followStatus,
            onFollowPressed: () => _handleFollowAction(state),
            onMessagePressed: () => _handleMessageAction(state.user!),
            onEditPressed: () => _handleEditProfile(),
          ),
        ),

        const SizedBox(height: 16),

        // Stats
        ProfileStats(
          user: state.user!,
          stats: state.stats,
          onStatsPressed: _handleStatsPressed,
        ),

        const SizedBox(height: 16),

        // Bio and Info
        if (state.user!.bio != null ||
            state.user!.website != null ||
            state.user!.location != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildProfileInfo(state.user!, colorScheme, theme),
          ),

        const SizedBox(height: 24),

        // Highlights
        if (state.highlights.isNotEmpty)
          ProfileHighlights(
            highlights: state.highlights,
            onHighlightPressed: _handleHighlightPressed,
          ),

        const SizedBox(height: 16),

        // Content Tabs
        ProfileContentTabs(
          user: state.user!,
          posts: state.posts,
          media: state.media,
          isLoadingPosts: state.isLoadingPosts,
          isLoadingMedia: state.isLoadingMedia,
          onPostPressed: _handlePostPressed,
          onLoadMorePosts: _handleLoadMorePosts,
          onLoadMoreMedia: _handleLoadMoreMedia,
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProfileInfo(
    UserEntity user,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.bio != null) ...[
            Text(
              user.bio!,
              style: theme.textTheme.p?.copyWith(
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (user.website != null) ...[
            _buildInfoRow(
              LucideIcons.globe,
              user.website!,
              colorScheme,
              theme,
              onTap: () => _launchUrl(user.website!),
            ),
          ],
          if (user.location != null) ...[
            _buildInfoRow(
              LucideIcons.mapPin,
              user.location!,
              colorScheme,
              theme,
            ),
          ],
          _buildInfoRow(
            LucideIcons.calendar,
            'Joined ${user.createdAt.displayDate}',
            colorScheme,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    ShadColorScheme colorScheme,
    ShadThemeData theme, {
    VoidCallback? onTap,
  }) {
    final child = Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.mutedForeground,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.small?.copyWith(
              color:
                  onTap != null ? colorScheme.primary : colorScheme.foreground,
            ),
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }

  // Event Handlers
  void _handleFollowAction(ProfileState state) {
    if (state.followStatus?.isFollowing == true) {
      context.read<ProfileBloc>().add(
            ProfileUnfollowRequested(userId: widget.userId),
          );
    } else {
      context.read<ProfileBloc>().add(
            ProfileFollowRequested(userId: widget.userId),
          );
    }
  }

  void _handleMessageAction(UserEntity user) {
    // Navigate to conversation page
    context.go('/messages/new?userId=${user.id}');
  }

  void _handleEditProfile() {
    context.go('/profile/edit');
  }

  void _handleStatsPressed(String type) {
    switch (type) {
      case 'followers':
        context.go('/profile/${widget.userId}/followers');
        break;
      case 'following':
        context.go('/profile/${widget.userId}/following');
        break;
      case 'posts':
        // Scroll to posts tab
        break;
    }
  }

  void _handleHighlightPressed(String highlightId) {
    // Navigate to story highlight view
    context.go('/stories/highlight/$highlightId');
  }

  void _handlePostPressed(String postId) {
    context.go('/posts/$postId');
  }

  void _handleLoadMorePosts() {
    context.read<ProfileBloc>().add(
          ProfileLoadMorePostsRequested(userId: widget.userId),
        );
  }

  void _handleLoadMoreMedia() {
    context.read<ProfileBloc>().add(
          ProfileLoadMoreMediaRequested(userId: widget.userId),
        );
  }

  void _showShareProfile(UserEntity? user) {
    if (user == null) return;

    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Share Profile'),
        description:
            Text('Share ${user.displayName ?? user.username}\'s profile'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadButton(
              onPressed: () {
                // Copy profile link
                context.pop();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.copy),
                  SizedBox(width: 8),
                  Text('Copy Link'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions(UserEntity? user) {
    if (user == null) return;

    showShadSheet(
      context: context,
      builder: (context) => ShadSheet(
        title: const Text('Profile Options'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.flag),
              title: const Text('Report Profile'),
              onTap: () {
                context.pop();
                _reportProfile(user);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.userX),
              title: const Text('Block User'),
              onTap: () {
                context.pop();
                _blockUser(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reportProfile(UserEntity user) {
    // Show report dialog
  }

  void _blockUser(UserEntity user) {
    // Show block confirmation dialog
  }

  void _launchUrl(String url) {
    // Launch URL
  }
}
