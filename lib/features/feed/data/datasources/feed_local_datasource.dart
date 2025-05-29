// lib/features/feed/data/datasources/feed_local_datasource.dart
import '../../../../core/storage/cache_manager.dart';
import '../../../../core/constants/storage_constants.dart';
import '../models/feed_model.dart';
import '../../domain/repositories/feed_repository.dart';

abstract class FeedLocalDataSource {
  Future<FeedModel?> getCachedFeed({
    required FeedType type,
  });

  Future<void> cacheFeed({
    required FeedType type,
    required FeedModel feed,
  });

  Future<void> clearFeedCache({
    FeedType? type,
  });

  Future<void> updatePostInCachedFeeds({
    required String postId,
    required Map<String, dynamic> updates,
  });
}

class FeedLocalDataSourceImpl implements FeedLocalDataSource {
  final CacheManager _cacheManager;

  FeedLocalDataSourceImpl(this._cacheManager);

  @override
  Future<FeedModel?> getCachedFeed({
    required FeedType type,
  }) async {
    try {
      final cacheKey = _getFeedCacheKey(type);
      final cachedData = await _cacheManager.getCachedData(cacheKey);

      if (cachedData != null) {
        return FeedModel.fromJson(cachedData);
      }

      return null;
    } catch (e) {
      // If cache is corrupted or can't be read, return null
      return null;
    }
  }

  @override
  Future<void> cacheFeed({
    required FeedType type,
    required FeedModel feed,
  }) async {
    try {
      final cacheKey = _getFeedCacheKey(type);
      await _cacheManager.cacheWithMediumExpiration(
        cacheKey,
        feed.toJson(),
      );
    } catch (e) {
      // Fail silently for caching errors
      // The app should still work without cache
    }
  }

  @override
  Future<void> clearFeedCache({
    FeedType? type,
  }) async {
    try {
      if (type != null) {
        final cacheKey = _getFeedCacheKey(type);
        await _cacheManager.removeCachedData(cacheKey);
      } else {
        // Clear all feed caches
        for (final feedType in FeedType.values) {
          final cacheKey = _getFeedCacheKey(feedType);
          await _cacheManager.removeCachedData(cacheKey);
        }
      }
    } catch (e) {
      // Fail silently for cache clearing errors
    }
  }

  @override
  Future<void> updatePostInCachedFeeds({
    required String postId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      // Update the post in all cached feeds
      for (final feedType in FeedType.values) {
        final cachedFeed = await getCachedFeed(type: feedType);
        if (cachedFeed != null) {
          // Find and update the post in the feed
          final updatedPosts = cachedFeed.feedPosts.map((post) {
            if (post.id == postId) {
              // Create a new post with updated data
              final postJson = post.toJson();
              postJson.addAll(updates);
              return PostModel.fromJson(postJson);
            }
            return post;
          }).toList();

          // Create updated feed model
          final updatedFeed = FeedModel(
            feedPosts: updatedPosts,
            feedPagination: cachedFeed.feedPagination,
            feedType: cachedFeed.feedType,
            lastRefreshed: cachedFeed.lastRefreshed,
            hasMore: cachedFeed.hasMore,
          );

          // Cache the updated feed
          await cacheFeed(type: feedType, feed: updatedFeed);
        }
      }
    } catch (e) {
      // Fail silently for update errors
    }
  }

  String _getFeedCacheKey(FeedType type) {
    switch (type) {
      case FeedType.personal:
        return '${StorageConstants.feedCache}personal';
      case FeedType.following:
        return '${StorageConstants.feedCache}following';
      case FeedType.trending:
        return '${StorageConstants.feedCache}trending';
      case FeedType.discover:
        return '${StorageConstants.feedCache}discover';
    }
  }
}
