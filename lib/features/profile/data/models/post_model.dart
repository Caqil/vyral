// lib/features/profile/data/models/post_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:vyral/core/utils/logger.dart';
import 'package:vyral/features/profile/domain/entities/post_entity.dart';
part 'post_model.g.dart';

@JsonSerializable()
class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.content,
    required super.contentType,
    required super.type,
    required super.visibility,
    super.mediaUrls,
    super.hashtags,
    super.mentions,
    super.location,
    super.likesCount,
    super.commentsCount,
    super.sharesCount,
    super.viewsCount,
    super.isLiked,
    super.isBookmarked,
    super.commentsEnabled,
    super.likesEnabled,
    super.sharesEnabled,
    super.isPinned,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different field mappings from API
      final String id = json['id'] as String? ?? '';
      final String authorId =
          json['user_id'] as String? ?? json['author_id'] as String? ?? '';
      final String content = json['content'] as String? ?? '';
      final String contentType = json['content_type'] as String? ?? 'text';
      final String type = json['type'] as String? ?? 'post';
      final String visibility = json['visibility'] as String? ?? 'public';

      // Handle media URLs
      List<String> mediaUrls = [];
      if (json['media_urls'] != null) {
        if (json['media_urls'] is List) {
          mediaUrls = List<String>.from(json['media_urls'] as List);
        }
      }

      // Handle hashtags - the API seems to return them differently
      List<String> hashtags = [];
      if (json['hashtags'] != null) {
        if (json['hashtags'] is List) {
          // Handle if it's already a proper list
          hashtags = (json['hashtags'] as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else if (json['hashtags'] is String) {
          // Handle if it's a string that needs parsing
          String hashtagString = json['hashtags'] as String;
          // Remove brackets and split by comma
          hashtagString = hashtagString.replaceAll(RegExp(r'[\[\]]'), '');
          hashtags = hashtagString
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }

      // Handle mentions
      List<String> mentions = [];
      if (json['mentions'] != null && json['mentions'] is List) {
        mentions = List<String>.from(json['mentions'] as List);
      }

      // Handle counts with proper null safety
      final int likesCount = (json['likes_count'] as num?)?.toInt() ?? 0;
      final int commentsCount = (json['comments_count'] as num?)?.toInt() ?? 0;
      final int sharesCount = (json['shares_count'] as num?)?.toInt() ?? 0;
      final int viewsCount = (json['views_count'] as num?)?.toInt() ?? 0;

      // Handle boolean fields
      final bool isLiked = json['is_liked'] as bool? ?? false;
      final bool isBookmarked =
          json['is_bookmarked'] as bool? ?? json['is_saved'] as bool? ?? false;
      final bool commentsEnabled = json['comments_enabled'] as bool? ?? true;
      final bool likesEnabled = json['likes_enabled'] as bool? ?? true;
      final bool sharesEnabled = json['shares_enabled'] as bool? ?? true;
      final bool isPinned = json['is_pinned'] as bool? ?? false;

      // Handle dates
      DateTime createdAt = DateTime.now();
      if (json['created_at'] != null) {
        try {
          createdAt = DateTime.parse(json['created_at'] as String);
        } catch (e) {
          AppLogger.debug('Error parsing created_at: $e');
        }
      }

      DateTime updatedAt = createdAt;
      if (json['updated_at'] != null) {
        try {
          updatedAt = DateTime.parse(json['updated_at'] as String);
        } catch (e) {
          AppLogger.debug('Error parsing updated_at: $e');
          updatedAt = createdAt;
        }
      }

      return PostModel(
        id: id,
        authorId: authorId,
        content: content,
        contentType: contentType,
        type: type,
        visibility: visibility,
        mediaUrls: mediaUrls,
        hashtags: hashtags,
        mentions: mentions,
        location: json['location'] as String?,
        likesCount: likesCount,
        commentsCount: commentsCount,
        sharesCount: sharesCount,
        viewsCount: viewsCount,
        isLiked: isLiked,
        isBookmarked: isBookmarked,
        commentsEnabled: commentsEnabled,
        likesEnabled: likesEnabled,
        sharesEnabled: sharesEnabled,
        isPinned: isPinned,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      AppLogger.debug('Error parsing PostModel from JSON: $e');
      AppLogger.debug('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}
