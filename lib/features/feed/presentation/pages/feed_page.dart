// lib/features/feed/presentation/pages/feed_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/repositories/feed_repository.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_state.dart';
import '../bloc/feed_event.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/feed_list.dart';
import '../widgets/post_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final List<FeedType> _feedTypes = [
    FeedType.personal,
    FeedType.following,
    FeedType.trending,
    FeedType.discover,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _feedTypes.length, vsync: this);
    _scrollController.addListener(_onScroll);

    // Load initial feed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedBloc>().loadInitialFeed();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _onScroll() {
    if (_isBottom && context.read<FeedBloc>().state.canLoadMore) {
      context.read<FeedBloc>().loadMorePosts();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final feedType = _feedTypes[_tabController.index];
    context.read<FeedBloc>().switchFeedType(feedType);
  }

  void _onRefresh() {
    context.read<FeedBloc>().refreshCurrentFeed();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Feed',
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              // Navigate to search
            },
          ),
        ],
        bottom: FeedTabBar(
          controller: _tabController,
          feedTypes: _feedTypes,
          onTap: (index) {
            final feedType = _feedTypes[index];
            context.read<FeedBloc>().switchFeedType(feedType);
          },
        ),
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state.hasError) {
            context.showErrorSnackBar(state.errorMessage!);
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: _feedTypes.map((feedType) {
              return _buildFeedContent(state, feedType);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create post
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeedContent(FeedState state, FeedType feedType) {
    // Show loading for initial load
    if (state.isLoading && state.posts.isEmpty) {
      return const LoadingWidget(message: 'Loading feed...');
    }

    // Show error for initial load failure
    if (state.hasError && state.posts.isEmpty) {
      return CustomErrorWidget(
        title: 'Failed to load feed',
        message: state.errorMessage ?? 'Something went wrong',
        onRetry: () => context.read<FeedBloc>().retry(),
      );
    }

    // Show empty state
    if (state.isEmpty) {
      return _buildEmptyState(feedType);
    }

    // Show feed list
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: FeedList(
        scrollController: _scrollController,
        posts: state.posts,
        isLoadingMore: state.isLoadingMore,
        isRefreshing: state.isRefreshing,
        onPostLike: (postId, isLiked) =>
            context.read<FeedBloc>().togglePostLike(postId, isLiked),
        onPostBookmark: (postId, isBookmarked) =>
            context.read<FeedBloc>().togglePostBookmark(postId, isBookmarked),
        onPostShare: (postId, comment) =>
            context.read<FeedBloc>().sharePost(postId, comment),
        onPostReport: (postId, reason, description) =>
            context.read<FeedBloc>().reportPost(postId, reason, description),
        onPostView: (postId, timeSpent) =>
            context.read<FeedBloc>().recordPostView(postId, 'feed', timeSpent),
      ),
    );
  }

  Widget _buildEmptyState(FeedType feedType) {
    switch (feedType) {
      case FeedType.personal:
        return const EmptyStateWidget(
          icon: Icons.dashboard_outlined,
          title: 'Welcome to your feed!',
          message:
              'Start following people and joining groups to see posts here.',
          actionText: 'Find Friends',
        );
      case FeedType.following:
        return const EmptyStateWidget(
          icon: Icons.people_outline,
          title: 'No posts from people you follow',
          message: 'Follow more people to see their posts here.',
          actionText: 'Discover People',
        );
      case FeedType.trending:
        return const EmptyStateWidget(
          icon: Icons.trending_up_outlined,
          title: 'No trending posts right now',
          message: 'Check back later for trending content.',
          actionText: 'Refresh',
        );
      case FeedType.discover:
        return const EmptyStateWidget(
          icon: Icons.explore_outlined,
          title: 'Nothing to discover yet',
          message: 'We\'re finding great content for you to discover.',
          actionText: 'Refresh',
        );
    }
  }
}
