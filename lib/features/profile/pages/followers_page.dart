// lib/features/profile/pages/followers_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../../../core/utils/logger.dart';
import '../bloc/follower_event.dart';
import '../bloc/follower_state.dart';
import '../bloc/followers_bloc.dart';
import '../presentation/widgets/user_list_item.dart';

class FollowersPage extends StatefulWidget {
  final String userId;
  final String? username;

  const FollowersPage({
    super.key,
    required this.userId,
    this.username,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial followers
    context.read<FollowersBloc>().add(
          FollowersLoadRequested(userId: widget.userId),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger load more when reaching 70% of scroll (more sensitive)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.7) {
      final state = context.read<FollowersBloc>().state;

      // Debug logging
      AppLogger.debug(
          '🔄 Scroll trigger - hasMoreData: ${state.hasMoreData}, isLoadingMore: ${state.isLoadingMore}');
      AppLogger.debug('📊 Current followers: ${state.followers.length}');

      if (state.hasMoreData && !state.isLoadingMore) {
        context.read<FollowersBloc>().add(
              FollowersLoadMoreRequested(userId: widget.userId),
            );
      }
    }
  }

  void _loadMore() {
    final state = context.read<FollowersBloc>().state;
    AppLogger.debug(
        '🔄 Manual load more - hasMoreData: ${state.hasMoreData}, isLoadingMore: ${state.isLoadingMore}');

    if (state.hasMoreData && !state.isLoadingMore) {
      context.read<FollowersBloc>().add(
            FollowersLoadMoreRequested(userId: widget.userId),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: CustomAppBar.simple(
        title: widget.username != null
            ? '${widget.username}\'s Followers'
            : 'Followers',
        automaticallyImplyLeading: true,
      ),
      body: BlocConsumer<FollowersBloc, FollowersState>(
        listener: (context, state) {
          // Debug logging
          AppLogger.debug('📱 FollowersBloc State Update:');
          AppLogger.debug('   - Followers count: ${state.followers.length}');
          AppLogger.debug('   - Has more data: ${state.hasMoreData}');
          AppLogger.debug('   - Is loading: ${state.isLoading}');
          AppLogger.debug('   - Is loading more: ${state.isLoadingMore}');
          AppLogger.debug('   - Current page: ${state.currentPage}');
        },
        builder: (context, state) {
          if (state.isLoading && state.followers.isEmpty) {
            return const LoadingWidget(message: 'Loading followers...');
          }

          if (state.hasError && state.followers.isEmpty) {
            AppLogger.debug(state.errorMessage!);
            return CustomErrorWidget(
              title: 'Failed to Load',
              message: state.errorMessage ?? 'Failed to load followers',
              onRetry: () => context.read<FollowersBloc>().add(
                    FollowersLoadRequested(userId: widget.userId),
                  ),
            );
          }

          if (state.followers.isEmpty && !state.isLoading) {
            return EmptyStateWidget(
              title: 'No Followers',
              message: widget.userId == 'current_user_id'
                  ? 'You don\'t have any followers yet. Start connecting with people!'
                  : 'This user doesn\'t have any followers yet.',
              icon: LucideIcons.users,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FollowersBloc>().add(
                    FollowersRefreshRequested(userId: widget.userId),
                  );
            },
            child: Column(
              children: [
                // Header with count and debug info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.card,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.totalCount ?? state.followers.length} followers',
                        style: theme.textTheme.large.copyWith(
                          color: colorScheme.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Debug info (remove in production)
                      if (state.followers.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Showing ${state.followers.length} • Page ${state.currentPage + 1} • ${state.hasMoreData ? 'More available' : 'All loaded'}',
                          style: theme.textTheme.small.copyWith(
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Followers List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.followers.length +
                        (state.hasMoreData || state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator or load more button at the end
                      if (index >= state.followers.length) {
                        if (state.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Loading more followers...'),
                                ],
                              ),
                            ),
                          );
                        } else if (state.hasMoreData) {
                          // Manual load more button
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: ShadButton.outline(
                                onPressed: _loadMore,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.chevronDown,
                                        size: 16),
                                    const SizedBox(width: 8),
                                    Text('Load More Followers'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final follower = state.followers[index];
                      return UserListItem(
                        user: follower,
                        onUserPressed: (user) => _navigateToProfile(user.id),
                        onFollowPressed: (user) => _handleFollowAction(user),
                        onMessagePressed: (user) => _navigateToMessage(user),
                      );
                    },
                  ),
                ),

                // Bottom indicator for completed loading
                if (!state.hasMoreData && state.followers.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.check,
                          size: 16,
                          color: colorScheme.mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'All followers loaded',
                          style: theme.textTheme.small.copyWith(
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToProfile(String userId) {
    context.push('/profile/$userId');
  }

  void _navigateToMessage(UserEntity user) {
    context.push('/messages/new?userId=${user.id}');
  }

  void _handleFollowAction(UserEntity user) {
    // Handle follow/unfollow action
    // This would typically trigger another bloc event
    AppLogger.debug('Follow action for user: ${user.username}');
  }
}
