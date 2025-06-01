// lib/features/profile/data/models/post_with_author_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:vyral/core/utils/logger.dart';
import '../../domain/entities/post_with_author_entity.dart';
import '../../../profile/data/models/user_model.dart';
import 'post_model.dart';

part 'post_with_author_model.g.dart';

@JsonSerializable()
class PostWithAuthorModel extends PostWithAuthorEntity {
  @JsonKey(name: 'post')
  final PostModel postModel;

  @JsonKey(name: 'author')
  final UserModel authorModel;

  const PostWithAuthorModel({
    required this.postModel,
    required this.authorModel,
  }) : super(post: postModel, author: authorModel);

  factory PostWithAuthorModel.fromJson(Map<String, dynamic> json) {
    try {
      PostModel post;
      UserModel author;

      // Check if the JSON structure has separate 'post' and 'author' fields
      if (json.containsKey('post') && json.containsKey('author')) {
        post = PostModel.fromJson(json['post'] as Map<String, dynamic>);
        author = UserModel.fromJson(json['author'] as Map<String, dynamic>);
      } else {
        // Handle flat structure where post and author data are mixed
        post = PostModel.fromJson(json);

        // Try to extract author data from the embedded 'author' field or create from user_id
        if (json['author'] != null && json['author'] is Map<String, dynamic>) {
          final authorData = json['author'] as Map<String, dynamic>;

          // Check if author data is valid (not all empty/null)
          final bool hasValidAuthorData =
              authorData['id']?.toString().isNotEmpty == true ||
                  authorData['username']?.toString().isNotEmpty == true ||
                  authorData['display_name']?.toString().isNotEmpty == true;

          if (hasValidAuthorData) {
            author = UserModel.fromJson(authorData);
          } else {
            // Create minimal author from post's user_id
            author = UserModel.fromJson({
              'id': json['user_id'] ?? '',
              'username': 'unknown_user',
              'email': '',
              'display_name': 'Unknown User',
              'is_verified': false,
              'is_active': true,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
        } else {
          // Create minimal author from post's user_id
          author = UserModel.fromJson({
            'id': json['user_id'] ?? '',
            'username': 'unknown_user',
            'email': '',
            'display_name': 'Unknown User',
            'is_verified': false,
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }

      return PostWithAuthorModel(
        postModel: post,
        authorModel: author,
      );
    } catch (e) {
      AppLogger.debug('Error parsing PostWithAuthorModel from JSON: $e');
      AppLogger.debug('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$PostWithAuthorModelToJson(this);
}
