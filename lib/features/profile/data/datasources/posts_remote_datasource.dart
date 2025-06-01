import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/api_response.dart';
import '../models/comment_with_author_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/like_model.dart';
import '../models/post_with_author_model.dart';

abstract class PostsRemoteDataSource {
  // Post operations
  Future<PostWithAuthorModel> getPost(String postId);
  Future<PostModel> updatePost(String postId, Map<String, dynamic> data);
  Future<void> deletePost(String postId);
  Future<LikeModel?> likePost(String postId, String reactionType);
  Future<bool> bookmarkPost(String postId);
  Future<void> sharePost(String postId);
  Future<void> reportPost(String postId, String reason, String? description);

  // Comment operations
  Future<List<CommentWithAuthorModel>> getPostComments(
      String postId, int page, int limit, String sortBy);
  Future<CommentWithAuthorModel> createComment(String postId, String content,
      String? parentCommentId, List<String> mentions);
  Future<CommentModel> updateComment(String commentId, String content);
  Future<void> deleteComment(String commentId);
  Future<LikeModel?> likeComment(String commentId, String reactionType);
  Future<List<CommentWithAuthorModel>> getCommentReplies(
      String commentId, int page, int limit);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final DioClient _dioClient;

  PostsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PostWithAuthorModel> getPost(String postId) async {
    try {
      final response = await _dioClient.get('/posts/$postId');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return PostWithAuthorModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get post');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  @override
  Future<PostModel> updatePost(String postId, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('/posts/$postId', data: data);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return PostModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to update post');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You don\'t have permission to update this post');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final response = await _dioClient.delete('/posts/$postId');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to delete post');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You don\'t have permission to delete this post');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  @override
  Future<LikeModel?> likePost(String postId, String reactionType) async {
    try {
      final response = await _dioClient.post('/posts/$postId/like', data: {
        'reaction_type': reactionType,
      });

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success) {
        // If data is null, it means the like was removed
        if (apiResponse.data != null) {
          return LikeModel.fromJson(apiResponse.data!);
        }
        return null;
      } else {
        throw Exception(apiResponse.message ?? 'Failed to like post');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  @override
  Future<bool> bookmarkPost(String postId) async {
    try {
      final response = await _dioClient.post('/posts/$postId/bookmark');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!['is_bookmarked'] as bool? ?? false;
      } else {
        throw Exception(apiResponse.message ?? 'Failed to bookmark post');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to bookmark post: $e');
    }
  }

  @override
  Future<void> sharePost(String postId) async {
    try {
      final response = await _dioClient.post('/posts/$postId/share');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to share post');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to share post: $e');
    }
  }

  @override
  Future<void> reportPost(
      String postId, String reason, String? description) async {
    try {
      final data = {
        'target_id': postId,
        'target_type': 'post',
        'reason': reason,
      };

      if (description != null) {
        data['description'] = description;
      }

      final response = await _dioClient.post('/reports', data: data);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to report post');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to report post: $e');
    }
  }

  @override
  Future<List<CommentWithAuthorModel>> getPostComments(
      String postId, int page, int limit, String sortBy) async {
    try {
      final response = await _dioClient.get(
        '/posts/$postId/comments',
        queryParameters: {
          'sort_by': sortBy,
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
            .map((comment) => CommentWithAuthorModel.fromJson(
                comment as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get comments');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  @override
  Future<CommentWithAuthorModel> createComment(String postId, String content,
      String? parentCommentId, List<String> mentions) async {
    try {
      final data = {
        'post_id': postId,
        'content': content,
        'content_type': 'text',
        'mentions': mentions,
      };

      if (parentCommentId != null) {
        data['parent_comment_id'] = parentCommentId;
      }

      final response = await _dioClient.post('/comments', data: data);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return CommentWithAuthorModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to create comment');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('Comments are disabled for this post');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  @override
  Future<CommentModel> updateComment(String commentId, String content) async {
    try {
      final response = await _dioClient.put('/comments/$commentId', data: {
        'content': content,
      });

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return CommentModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Failed to update comment');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Comment not found');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You don\'t have permission to update this comment');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final response = await _dioClient.delete('/comments/$commentId');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to delete comment');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Comment not found');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You don\'t have permission to delete this comment');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  @override
  Future<LikeModel?> likeComment(String commentId, String reactionType) async {
    try {
      final response =
          await _dioClient.post('/comments/$commentId/like', data: {
        'reaction_type': reactionType,
      });

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success) {
        // If data is null, it means the like was removed
        if (apiResponse.data != null) {
          return LikeModel.fromJson(apiResponse.data!);
        }
        return null;
      } else {
        throw Exception(apiResponse.message ?? 'Failed to like comment');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Comment not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  @override
  Future<List<CommentWithAuthorModel>> getCommentReplies(
      String commentId, int page, int limit) async {
    try {
      final response = await _dioClient.get(
        '/comments/$commentId/replies',
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
            .map((reply) =>
                CommentWithAuthorModel.fromJson(reply as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get replies');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Comment not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get replies: $e');
    }
  }
}
