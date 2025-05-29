// lib/features/feed/presentation/widgets/feed_tab_bar.dart
import 'package:flutter/material.dart';
import '../../domain/repositories/feed_repository.dart';

class FeedTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<FeedType> feedTypes;
  final Function(int)? onTap;

  const FeedTabBar({
    super.key,
    required this.controller,
    required this.feedTypes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: TabBar(
          controller: controller,
          onTap: onTap,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          dividerColor: Colors.transparent,
          tabs: feedTypes.map((type) {
            return Tab(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFeedTypeIcon(type),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(_getFeedTypeDisplayName(type)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFeedTypeDisplayName(FeedType type) {
    switch (type) {
      case FeedType.personal:
        return 'For You';
      case FeedType.following:
        return 'Following';
      case FeedType.trending:
        return 'Trending';
      case FeedType.discover:
        return 'Discover';
    }
  }

  IconData _getFeedTypeIcon(FeedType type) {
    switch (type) {
      case FeedType.personal:
        return Icons.home;
      case FeedType.following:
        return Icons.people;
      case FeedType.trending:
        return Icons.trending_up;
      case FeedType.discover:
        return Icons.explore;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
