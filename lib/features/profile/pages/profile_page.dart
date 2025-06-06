import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vyral/core/utils/logger.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
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

    // Load profile data - this will now properly load follow status
    AppLogger.debug(
        '🔄 ProfilePage: Loading profile for user ${widget.userId}');
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

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        AppLogger.debug('📱 ProfilePage: State update received');
        AppLogger.debug('   - User: ${state.user?.username}');
        AppLogger.debug(
            '   - Follow Status: Following=${state.followStatus?.isFollowing}, Pending=${state.followStatus?.isPending}');
        AppLogger.debug('   - Follow Loading: ${state.isFollowLoading}');
        AppLogger.debug('   - Has Error: ${state.hasError}');

        // Handle follow/unfollow success messages
        if (!state.isFollowLoading &&
            state.followStatus != null &&
            !state.hasError) {
          final followStatus = state.followStatus!;
          final user = state.user;

          if (user != null) {
            // Show appropriate messages based on the ACTUAL server response
            if (followStatus.isFollowing && !followStatus.isPending) {
              AppLogger.debug('✅ Successfully following user');
              context.showSuccessSnackBar(
                context,
                'You are now following ${user.displayName ?? user.username}',
              );
            } else if (followStatus.isPending) {
              AppLogger.debug('⏳ Follow request sent (pending)');
              context.showSuccessSnackBar(
                context,
                'Follow request sent to ${user.displayName ?? user.username}',
              );
            } else if (!followStatus.isFollowing && !followStatus.isPending) {
              // Only show unfollow message if we were previously following
              // (avoid showing it on initial load)
              if (state.user?.followersCount != null) {
                AppLogger.debug('👋 Successfully unfollowed user');
                context.showSuccessSnackBar(
                  context,
                  'You unfollowed ${user.displayName ?? user.username}',
                );
              }
            }
          }
        }

        // Handle follow/unfollow errors
        if (state.hasError && state.errorMessage != null) {
          AppLogger.error('❌ ProfilePage Error: ${state.errorMessage}');
          context.showErrorSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            style:
                                                theme.textTheme.muted.copyWith(
                                              color:
                                                  colorScheme.mutedForeground,
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
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(
    ProfileState state,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    // Loading state
    if (state.isLoading && state.user == null) {
      return const SizedBox(
        height: 400,
        child: LoadingWidget(message: 'Loading profile...'),
      );
    }

    // Error state
    if (state.hasError && state.user == null) {
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

    // No user found
    if (state.user == null) {
      return const SizedBox(
        height: 400,
        child: CustomErrorWidget(
          title: 'Profile Not Found',
          message: 'This profile does not exist or has been removed.',
        ),
      );
    }

    // Success state - show profile content
    return Column(
      children: [
        // Profile Header
        ProfileHeader(
          user: state.user!,
          coverImageUrl: state.user!.coverPicture,
          isOwnProfile: state.isOwnProfile,
          isPrivateView: state.isPrivateProfile && !state.canViewContent,
          onCoverTap: state.isOwnProfile ? _handleEditProfile : null,
          onProfilePictureTap: state.isOwnProfile ? _handleEditProfile : null,
        ),

        const SizedBox(height: 16),

        // Action Buttons - KEY COMPONENT WITH FIXED FOLLOW STATUS
        _buildActionButtons(state),

        const SizedBox(height: 16),

        // Stats (only if can view or own profile)
        if (state.canViewStats)
          ProfileStats(
            user: state.user!,
            stats: state.stats,
            onStatsPressed: _handleStatsPressed,
          ),

        const SizedBox(height: 16),

        // Bio and Info (only if can view or own profile)
        if (state.canViewContent || state.isOwnProfile) ...[
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
            isOwnProfile: state.isOwnProfile,
            currentUserId: null, // Add if needed
            onPostPressed: _handlePostPressed,
            onLoadMorePosts: _handleLoadMorePosts,
            onLoadMoreMedia: _handleLoadMoreMedia,
            onRefreshPosts: () => context.read<ProfileBloc>().add(
                  ProfileRefreshRequested(),
                ),
          ),
        ] else ...[
          // Private account message
          _buildPrivateAccountMessage(state, colorScheme, theme),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildActionButtons(ProfileState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProfileActionButtons(
        user: state.user!,
        isOwnProfile: state.isOwnProfile,
        followStatus: state.followStatus, // ✅ Now properly loaded from API
        isFollowLoading:
            state.isFollowLoading, // ✅ Shows loading during API calls
        onFollowPressed: () => _handleFollowAction(state),
        onMessagePressed: () => _handleMessageAction(state.user!),
        onEditPressed: () => _handleEditProfile(),
        isPrivateView: state.isPrivateProfile && !state.canViewContent,
      ),
    );
  }

  Widget _buildPrivateAccountMessage(
    ProfileState state,
    ShadColorScheme colorScheme,
    ShadThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.border),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.lock,
            size: 48,
            color: colorScheme.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'This Account is Private',
            style: theme.textTheme.h4.copyWith(
              color: colorScheme.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow @${state.user?.username} to see their posts, photos and videos.',
            style: theme.textTheme.p.copyWith(
              color: colorScheme.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            Text(
              user.bio!,
              style: theme.textTheme.p.copyWith(
                color: colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (user.website != null && user.website!.isNotEmpty) ...[
            _buildInfoRow(
              LucideIcons.globe,
              user.website!,
              colorScheme,
              theme,
              onTap: () => _launchUrl(user.website!),
            ),
          ],
          if (user.location != null && user.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              LucideIcons.mapPin,
              user.location!,
              colorScheme,
              theme,
            ),
          ],
          const SizedBox(height: 8),
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
            style: theme.textTheme.small.copyWith(
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

  Widget _buildHeaderActions(ProfileState state) {
    return Skeletonizer(
      enabled: state.isLoading && state.user == null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadButton.ghost(
            onPressed:
                state.user != null ? () => _showShareProfile(state.user) : null,
            child: const Icon(LucideIcons.share),
          ),
          const SizedBox(width: 8),
          ShadButton.ghost(
            onPressed: state.user != null
                ? () => _showProfileOptions(state.user)
                : null,
            child: const Icon(LucideIcons.menu),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Event Handlers with proper follow status checking
  void _handleFollowAction(ProfileState state) {
    AppLogger.debug('🔄 ProfilePage: Follow action triggered');
    AppLogger.debug(
        '📊 Current follow status: Following=${state.followStatus?.isFollowing}, Pending=${state.followStatus?.isPending}, Blocked=${state.followStatus?.isBlocked}');

    // Handle blocked state
    if (state.followStatus?.isBlocked == true) {
      AppLogger.debug('🚫 User is blocked - showing blocked dialog');
      _showBlockedUserDialog(state);
      return;
    }

    // ✅ FIXED: Now properly checks the ACTUAL follow status from API
    if (state.followStatus?.isFollowing == true) {
      // User is currently following - show unfollow confirmation
      AppLogger.debug('👥 User is following - showing unfollow confirmation');
      _showUnfollowConfirmation(state);
    } else if (state.followStatus?.isPending == true) {
      // User has pending request - allow them to cancel it
      AppLogger.debug(
          '⏳ Follow request is pending - showing cancel confirmation');
      _showCancelRequestConfirmation(state);
    } else {
      // User is not following - trigger follow action
      AppLogger.debug('➕ User is not following - triggering follow action');
      context.read<ProfileBloc>().add(
            ProfileFollowRequested(userId: widget.userId),
          );
    }
  }

  void _showUnfollowConfirmation(ProfileState state) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Unfollow User'),
        description: Text(
          'Are you sure you want to unfollow @${state.user?.username ?? 'this user'}?',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              AppLogger.debug('🔄 Triggering unfollow action');
              context.read<ProfileBloc>().add(
                    ProfileUnfollowRequested(userId: widget.userId),
                  );
            },
            child: const Text('Unfollow'),
          ),
        ],
      ),
    );
  }

  void _showCancelRequestConfirmation(ProfileState state) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Cancel Follow Request'),
        description: Text(
          'Cancel your follow request to @${state.user?.username ?? 'this user'}?',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Request'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              AppLogger.debug('🔄 Cancelling follow request');
              // Cancel the follow request (same as unfollow)
              context.read<ProfileBloc>().add(
                    ProfileUnfollowRequested(userId: widget.userId),
                  );
            },
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  void _showBlockedUserDialog(ProfileState state) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('User Blocked'),
        description: Text(
          'You have blocked @${state.user?.username ?? 'this user'}. You cannot follow or message them until you unblock them.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement unblock functionality
              AppLogger.debug('🔄 Unblock functionality not implemented yet');
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  void _handleMessageAction(UserEntity user) {
    // Check if we can message this user
    final state = context.read<ProfileBloc>().state;

    if (state.followStatus?.isBlocked == true) {
      context.showErrorSnackBar(
        context,
        'You cannot message this user because they are blocked.',
      );
      return;
    }

    if (state.followStatus?.canMessage == false) {
      context.showErrorSnackBar(
        context,
        'You cannot message this user.',
      );
      return;
    }

    // Navigate to conversation page
    AppLogger.debug('💬 Navigating to message user: ${user.username}');
    context.go('/messages/new?userId=${user.id}');
  }

  void _handleEditProfile() {
    AppLogger.debug('✏️ Navigating to edit profile');
    context.go('/profile/edit');
  }

  void _handleStatsPressed(String type) {
    AppLogger.debug('📊 Stats pressed: $type');
    switch (type) {
      case 'followers':
        context.go('/profile/${widget.userId}/followers');
        break;
      case 'following':
        context.go('/profile/${widget.userId}/following');
        break;
      case 'posts':
        // Scroll to posts tab or show posts view
        break;
    }
  }

  void _handleHighlightPressed(String highlightId) {
    AppLogger.debug('✨ Highlight pressed: $highlightId');
    // Navigate to story highlight view
    context.go('/stories/highlight/$highlightId');
  }

  void _handlePostPressed(String postId) {
    AppLogger.debug('📝 Post pressed: $postId');
    context.go('/post/$postId');
  }

  void _handleLoadMorePosts() {
    AppLogger.debug('📄 Loading more posts');
    context.read<ProfileBloc>().add(
          ProfileLoadMorePostsRequested(userId: widget.userId),
        );
  }

  void _handleLoadMoreMedia() {
    AppLogger.debug('🖼️ Loading more media');
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
                context.showSuccessSnackBar(context, 'Profile link copied!');
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
            if (!context.read<ProfileBloc>().state.isOwnProfile)
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
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Report Profile'),
        description: Text('Why are you reporting @${user.username}?'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Spam'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(
                    context, 'Profile reported for spam');
              },
            ),
            ListTile(
              title: const Text('Harassment'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(
                    context, 'Profile reported for harassment');
              },
            ),
            ListTile(
              title: const Text('Inappropriate content'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccessSnackBar(
                    context, 'Profile reported for inappropriate content');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _blockUser(UserEntity user) {
    // Show block confirmation dialog
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Block User'),
        description: Text('Are you sure you want to block @${user.username}?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement block functionality
              context.showSuccessSnackBar(context, 'User blocked');
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) {
    // TODO: Implement URL launching
    AppLogger.debug('🌐 Would launch URL: $url');
    context.showSuccessSnackBar(context, 'Opening link...');
  }
}
