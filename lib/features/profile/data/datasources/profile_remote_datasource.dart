// lib/features/profile/data/datasources/profile_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:vyral/features/profile/data/models/follow_status_model.dart';
import 'package:vyral/features/profile/data/models/post_model.dart';
import 'package:vyral/features/profile/data/models/story_highlight_model.dart';
import 'package:vyral/features/profile/data/models/user_stats_model.dart';
import 'package:vyral/shared/models/media_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/models/api_response.dart';
import '../models/user_model.dart';

abstract class ProfileRemoteDataSource {
  // Current user profile (my profile)
  Future<UserModel> getCurrentUserProfile();

  // Other user's profile
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> getUserByUsername(String username);

  // Profile stats and status
  Future<UserStatsModel> getUserStats(String userId);
  Future<FollowStatusModel> getFollowStatus(String userId);

  // Follow operations
  Future<FollowStatusModel> followUser(String userId);
  Future<FollowStatusModel> unfollowUser(String userId);

  // User content
  Future<List<PostModel>> getUserPosts(String userId, int page, int limit);
  Future<List<MediaModel>> getUserMedia(
      String userId, int page, int limit, String? type);
  Future<List<StoryHighlightModel>> getUserHighlights(String userId);

  // Follow lists
  Future<List<UserModel>> getFollowers(String userId, int page, int limit);
  Future<List<UserModel>> getFollowing(String userId, int page, int limit);

  // Profile updates
  Future<UserModel> updateProfile(Map<String, dynamic> data);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> getCurrentUserProfile() async {
    try {
      final response = await _dioClient.get('/auth/profile');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(
            apiResponse.message ?? 'Failed to get current user profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get current user profile: $e');
    }
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await _dioClient.get('/users/$userId');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get user profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('This profile is private');
      } else if (e.response?.statusCode == 423) {
        throw Exception('This account has been suspended');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<UserModel> getUserByUsername(String username) async {
    try {
      final response = await _dioClient.get('/users/username/$username');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'User not found');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 403) {
        throw Exception('This profile is private');
      } else if (e.response?.statusCode == 423) {
        throw Exception('This account has been suspended');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<UserStatsModel> getUserStats(String userId) async {
    try {
      final response = await _dioClient.get('/users/$userId/stats');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return UserStatsModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get user stats');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Cannot view stats for private profile');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  @override
  Future<FollowStatusModel> getFollowStatus(String userId) async {
    try {
      final response = await _dioClient.get('/users/$userId/follow-status');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return FollowStatusModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get follow status');
      }
    } catch (e) {
      throw Exception('Failed to get follow status: $e');
    }
  }

  @override
  Future<FollowStatusModel> followUser(String userId) async {
    try {
      final response = await _dioClient.post('/users/$userId/follow');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return FollowStatusModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to follow user');
      }
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  @override
  Future<FollowStatusModel> unfollowUser(String userId) async {
    try {
      final response = await _dioClient.delete('/users/$userId/follow');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return FollowStatusModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to unfollow user');
      }
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(
      String userId, int page, int limit) async {
    try {
      final response = await _dioClient.get(
        '/posts/user/$userId',
        queryParameters: {
          'limit': limit,
          'skip': page * limit,
        },
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((post) => PostModel.fromJson(post as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get user posts');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Cannot view posts from private profile');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user posts: $e');
    }
  }

  @override
  Future<List<MediaModel>> getUserMedia(
      String userId, int page, int limit, String? type) async {
    try {
      final queryParams = {
        'limit': limit,
        'skip': page * limit,
      };

      if (type != null) {
        queryParams['type'] = int.parse(type);
      }

      final response = await _dioClient.get(
        '/media/user/$userId',
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((media) => MediaModel.fromJson(media as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get user media');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Cannot view media from private profile');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user media: $e');
    }
  }

  @override
  Future<List<StoryHighlightModel>> getUserHighlights(String userId) async {
    try {
      final response = await _dioClient.get('/story-highlights/user/$userId');

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((highlight) =>
                StoryHighlightModel.fromJson(highlight as Map<String, dynamic>))
            .toList();
      } else {
        return []; // Return empty list if no highlights
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return []; // Return empty list for private profiles
      }
      return []; // Return empty list on other errors
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  @override
  Future<List<UserModel>> getFollowers(
      String userId, int page, int limit) async {
    try {
      final response = await _dioClient.get(
        '/users/$userId/followers',
        queryParameters: {
          'limit': limit,
          'skip': page * limit,
        },
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get followers');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Cannot view followers of private profile');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  @override
  Future<List<UserModel>> getFollowing(
      String userId, int page, int limit) async {
    try {
      final response = await _dioClient.get(
        '/users/$userId/following',
        queryParameters: {
          'limit': limit,
          'skip': page * limit,
        },
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get following');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Cannot view following of private profile');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('/users/profile', data: data);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
