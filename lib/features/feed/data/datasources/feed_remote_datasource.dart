// lib/features/feed/data/datasources/feed_remote_datasource.dart
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/models/api_response.dart';
import '../models/feed_model.dart';
import '../../domain/repositories/feed_repository.dart';

abstract class FeedRemoteDataSource {
  Future<FeedModel> getFeed({
    required FeedType type,
    int limit = 20,
    int skip = 0,
    bool refresh = false,
  });

  Future<void> recordInteraction({
    required String postId,
    required String interactionType,
    required String source,
    int? timeSpent,
  });

  Future<void> refreshFeed({
    required FeedType feedType,
  });

  Future<PostModel> likePost({
    required String postId,
    required String reactionType,
  });

  Future<PostModel> unlikePost({
    required String postId,
  });

  Future<PostModel> bookmarkPost({
    required String postId,
  });

  Future<PostModel> removeBookmark({
    required String postId,
  });

  Future<PostModel> sharePost({
    required String postId,
    String? comment,
  });

  Future<void> reportPost({
    required String postId,
    required String reason,
    String? description,
  });
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final DioClient _dioClient;

  FeedRemoteDataSourceImpl(this._dioClient);

  @override
  Future<FeedModel> getFeed({
    required FeedType type,
    int limit = 20,
    int skip = 0,
    bool refresh = false,
  }) async {
    try {
      final queryParams = {
        'type': _feedTypeToString(type),
        'limit': limit,
        'skip': skip,
        'refresh': refresh,
      };

      final response = await _dioClient.get(
        ApiConstants.feed,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return FeedModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get feed');
      }
    } catch (e) {
      throw Exception('Failed to get feed: $e');
    }
  }

  @override
  Future<void> recordInteraction({
    required String postId,
    required String interactionType,
    required String source,
    int? timeSpent,
  }) async {
    try {
      final data = {
        'post_id': postId,
        'interaction_type': interactionType,
        'source': source,
        if (timeSpent != null) 'time_spent': timeSpent,
      };

      final response = await _dioClient.post(
        ApiConstants.feedInteractions,
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to record interaction');
      }
    } catch (e) {
      throw Exception('Failed to record interaction: $e');
    }
  }

  @override
  Future<void> refreshFeed({
    required FeedType feedType,
  }) async {
    try {
      final data = {
        'feed_type': _feedTypeToString(feedType),
      };

      final response = await _dioClient.post(
        ApiConstants.refreshFeed,
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to refresh feed');
      }
    } catch (e) {
      throw Exception('Failed to refresh feed: $e');
    }
  }

  @override
  Future<PostModel> likePost({
    required String postId,
    required String reactionType,
  }) async {
    try {
      final data = {
        'reaction_type': reactionType,
      };

      final response = await _dioClient.post(
        ApiConstants.likePost.replaceAll('{id}', postId),
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return PostModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to like post');
      }
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  @override
  Future<PostModel> unlikePost({
    required String postId,
  }) async {
    try {
      final response = await _dioClient.delete(
        ApiConstants.likePost.replaceAll('{id}', postId),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return PostModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to unlike post');
      }
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  @override
  Future<PostModel> bookmarkPost({
    required String postId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/posts/$postId/bookmark', // Add this to ApiConstants
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return PostModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to bookmark post');
      }
    } catch (e) {
      throw Exception('Failed to bookmark post: $e');
    }
  }

  @override
  Future<PostModel> removeBookmark({
    required String postId,
  }) async {
    try {
      final response = await _dioClient.delete(
        '/posts/$postId/bookmark', // Add this to ApiConstants
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return PostModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to remove bookmark');
      }
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  @override
  Future<PostModel> sharePost({
    required String postId,
    String? comment,
  }) async {
    try {
      final data = {
        'post_id': postId,
        if (comment != null) 'comment': comment,
      };

      final response = await _dioClient.post(
        '/posts/$postId/share', // Add this to ApiConstants
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return PostModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to share post');
      }
    } catch (e) {
      throw Exception('Failed to share post: $e');
    }
  }

  @override
  Future<void> reportPost({
    required String postId,
    required String reason,
    String? description,
  }) async {
    try {
      final data = {
        'reason': reason,
        if (description != null) 'description': description,
      };

      final response = await _dioClient.post(
        ApiConstants.reportPost.replaceAll('{id}', postId),
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to report post');
      }
    } catch (e) {
      throw Exception('Failed to report post: $e');
    }
  }

  String _feedTypeToString(FeedType type) {
    switch (type) {
      case FeedType.personal:
        return 'personal';
      case FeedType.following:
        return 'following';
      case FeedType.trending:
        return 'trending';
      case FeedType.discover:
        return 'discover';
    }
  }
}
