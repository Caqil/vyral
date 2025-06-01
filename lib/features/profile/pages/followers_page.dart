// lib/features/profile/presentation/pages/followers_page.dart
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
import '../presentation/bloc/follower_event.dart';
import '../presentation/bloc/follower_state.dart';
import '../presentation/bloc/followers_bloc.dart';
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
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
      body: BlocBuilder<FollowersBloc, FollowersState>(
        builder: (context, state) {
          if (state.isLoading && state.followers.isEmpty) {
            return const LoadingWidget(message: 'Loading followers...');
          }

          if (state.hasError && state.followers.isEmpty) {
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
              message: widget.userId ==
                      'current_user_id' // Check if own profile
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
                    '${state.totalCount ?? state.followers.length} followers',
                    style: theme.textTheme.large?.copyWith(
                      color: colorScheme.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Followers List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount:
                        state.followers.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.followers.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
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
    // Handle follow/unfollow action
    // This would typically trigger another bloc event
  }
}


