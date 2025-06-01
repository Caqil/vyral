// lib/features/profile/data/repositories/posts_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_with_author_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/comment_with_author_entity.dart';
import '../../domain/entities/like_entity.dart';
import '../datasources/posts_remote_datasource.dart';
import 'posts_repository.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;

  PostsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PostWithAuthorEntity>> getPost(String postId) async {
    try {
      final postWithAuthor = await remoteDataSource.getPost(postId);
      return Right(postWithAuthor);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost(
      String postId, Map<String, dynamic> data) async {
    try {
      final post = await remoteDataSource.updatePost(postId, data);
      return Right(post);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, LikeEntity?>> likePost(
      String postId, String reactionType) async {
    try {
      final like = await remoteDataSource.likePost(postId, reactionType);
      return Right(like);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> bookmarkPost(String postId) async {
    try {
      final isBookmarked = await remoteDataSource.bookmarkPost(postId);
      return Right(isBookmarked);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sharePost(String postId) async {
    try {
      await remoteDataSource.sharePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reportPost(
      String postId, String reason, String? description) async {
    try {
      await remoteDataSource.reportPost(postId, reason, description);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommentWithAuthorEntity>>> getPostComments(
    String postId,
    int page,
    int limit,
    String sortBy,
  ) async {
    try {
      final comments =
          await remoteDataSource.getPostComments(postId, page, limit, sortBy);
      // Cast List<CommentWithAuthorModel> to List<CommentWithAuthorEntity>
      return Right(comments.cast<CommentWithAuthorEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentWithAuthorEntity>> createComment(
    String postId,
    String content,
    String? parentCommentId,
    List<String> mentions,
  ) async {
    try {
      final comment = await remoteDataSource.createComment(
          postId, content, parentCommentId, mentions);
      return Right(comment);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment(
      String commentId, String content) async {
    try {
      final comment = await remoteDataSource.updateComment(commentId, content);
      return Right(comment);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, LikeEntity?>> likeComment(
      String commentId, String reactionType) async {
    try {
      final like = await remoteDataSource.likeComment(commentId, reactionType);
      return Right(like);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommentWithAuthorEntity>>> getCommentReplies(
    String commentId,
    int page,
    int limit,
  ) async {
    try {
      final replies =
          await remoteDataSource.getCommentReplies(commentId, page, limit);
      // Cast List<CommentWithAuthorModel> to List<CommentWithAuthorEntity>
      return Right(replies.cast<CommentWithAuthorEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
    }
  }
}
