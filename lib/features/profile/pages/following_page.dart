import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vyral/core/utils/extensions.dart';

import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../domain/entities/user_entity.dart';
import '../presentation/bloc/following_bloc.dart';
import '../presentation/bloc/following_event.dart';
import '../presentation/bloc/following_state.dart';
import '../presentation/widgets/user_list_item.dart';

class FollowingPage extends StatefulWidget {
  final String userId;
  final String? username;

  const FollowingPage({
    super.key,
    required this.userId,
    this.username,
  });

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    context.read<FollowingBloc>().add(
          FollowingLoadRequested(userId: widget.userId),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<FollowingBloc>().add(
            FollowingLoadMoreRequested(userId: widget.userId),
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
            ? '${widget.username}\'s Following'
            : 'Following',
        automaticallyImplyLeading: true,
      ),
      body: BlocBuilder<FollowingBloc, FollowingState>(
        builder: (context, state) {
          if (state.isLoading && state.following.isEmpty) {
            return const LoadingWidget(message: 'Loading following...');
          }

          if (state.hasError && state.following.isEmpty) {
            return CustomErrorWidget(
              title: 'Failed to Load',
              message: state.errorMessage ?? 'Failed to load following',
              onRetry: () => context.read<FollowingBloc>().add(
                    FollowingLoadRequested(userId: widget.userId),
                  ),
            );
          }

          if (state.following.isEmpty && !state.isLoading) {
            return EmptyStateWidget(
              title: 'Not Following Anyone',
              message:
                  widget.userId == 'current_user_id' // Check if own profile
                      ? 'You\'re not following anyone yet. Discover new people!'
                      : 'This user isn\'t following anyone yet.',
              icon: LucideIcons.userPlus,
              actionText:
                  widget.userId == 'current_user_id' ? 'Discover People' : null,
              onAction: widget.userId == 'current_user_id'
                  ? () {
                      context.go('/search');
                    }
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FollowingBloc>().add(
                    FollowingRefreshRequested(userId: widget.userId),
                  );
            },
            child: Column(
              children: [
                // Header with count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.card,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.border),
                    ),
                  ),
                  child: Text(
                    '${state.totalCount ?? state.following.length} following',
                    style: theme.textTheme.large?.copyWith(
                      color: colorScheme.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Following List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount:
                        state.following.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.following.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final followedUser = state.following[index];
                      return UserListItem(
                        user: followedUser,
                        onUserPressed: (user) => _navigateToProfile(user.id),
                        onFollowPressed: (user) => _handleFollowAction(user),
                        onMessagePressed: (user) => _navigateToMessage(user),
                        showFollowButton: widget.userId ==
                            'current_user_id', // Only show for own profile
                      );
                    },
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
    context.go('/profile/$userId');
  }

  void _navigateToMessage(UserEntity user) {
    context.go('/messages/new?userId=${user.id}');
  }

  void _handleFollowAction(UserEntity user) {
    // Handle unfollow action for following list
    context.read<FollowingBloc>().add(
          FollowingUnfollowRequested(
            userId: widget.userId,
            targetUserId: user.id,
          ),
        );
  }
}
