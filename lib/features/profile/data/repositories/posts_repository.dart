// lib/features/posts/domain/repositories/posts_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/comment_with_author_entity.dart';
import '../../domain/entities/like_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_with_author_entity.dart';

abstract class PostsRepository {
  // Post operations
  Future<Either<Failure, PostWithAuthorEntity>> getPost(String postId);
  Future<Either<Failure, PostEntity>> updatePost(String postId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deletePost(String postId);
  Future<Either<Failure, LikeEntity?>> likePost(String postId, String reactionType);
  Future<Either<Failure, bool>> bookmarkPost(String postId);
  Future<Either<Failure, void>> sharePost(String postId);
  Future<Either<Failure, void>> reportPost(String postId, String reason, String? description);

  // Comment operations
  Future<Either<Failure, List<CommentWithAuthorEntity>>> getPostComments(
    String postId, 
    int page, 
    int limit, 
    String sortBy,
  );
  Future<Either<Failure, CommentWithAuthorEntity>> createComment(
    String postId, 
    String content, 
    String? parentCommentId, 
    List<String> mentions,
  );
  Future<Either<Failure, CommentEntity>> updateComment(String commentId, String content);
  Future<Either<Failure, void>> deleteComment(String commentId);
  Future<Either<Failure, LikeEntity?>> likeComment(String commentId, String reactionType);
  Future<Either<Failure, List<CommentWithAuthorEntity>>> getCommentReplies(
    String commentId, 
    int page, 
    int limit,
  );
}
