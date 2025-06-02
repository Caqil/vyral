import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/features/profile/data/models/comment_model.dart';
import 'package:vyral/features/profile/domain/entities/post_entity.dart';
import 'package:vyral/features/profile/domain/usecases/get_post_usecase.dart';
import 'package:vyral/features/profile/domain/usecases/get_post_comments_usecase.dart';
import 'package:vyral/features/profile/domain/usecases/like_post_usecase.dart';
import 'package:vyral/features/profile/domain/usecases/create_comment_usecase.dart';
import 'package:vyral/features/profile/domain/usecases/like_comment_usecase.dart';

import 'post_detail_event.dart';
import 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final GetPostUseCase getPost;
  final GetPostCommentsUseCase getPostComments;
  final LikePostUseCase likePost;
  final CreateCommentUseCase createComment;
  final LikeCommentUseCase likeComment;

  PostDetailBloc({
    required this.getPost,
    required this.getPostComments,
    required this.likePost,
    required this.createComment,
    required this.likeComment,
  }) : super(const PostDetailState()) {
    on<PostDetailLoadRequested>(_onLoadRequested);
    on<PostDetailLikeToggled>(_onLikeToggled);
    on<PostDetailBookmarkToggled>(_onBookmarkToggled);
    on<PostDetailCommentSubmitted>(_onCommentSubmitted);
    on<PostDetailCommentLikeToggled>(_onCommentLikeToggled);
    on<PostDetailLoadMoreCommentsRequested>(_onLoadMoreCommentsRequested);
  }

  Future<void> _onLoadRequested(
    PostDetailLoadRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // This would typically load the post and its comments
    // For now, we'll simulate it
    await Future.delayed(const Duration(seconds: 1));

    // Create a dummy post for demonstration
    final dummyPost = PostEntity(
      id: event.postId,
      authorId: 'dummy_author',
      content: 'This is a sample post content for demonstration purposes.',
      contentType: 'text',
      type: 'regular',
      visibility: 'public',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    emit(state.copyWith(
      isLoading: false,
      post: dummyPost,
      author: null, // Would be loaded separately
    ));
  }

  Future<void> _onLikeToggled(
    PostDetailLikeToggled event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state.post == null) return;

    // Optimistically update the UI
    final updatedPost = PostEntity(
      id: state.post!.id,
      authorId: state.post!.authorId,
      content: state.post!.content,
      contentType: state.post!.contentType,
      type: state.post!.type,
      visibility: state.post!.visibility,
      mediaUrls: state.post!.mediaUrls,
      hashtags: state.post!.hashtags,
      mentions: state.post!.mentions,
      location: state.post!.location,
      likesCount: state.post!.isLiked
          ? state.post!.likesCount - 1
          : state.post!.likesCount + 1,
      commentsCount: state.post!.commentsCount,
      sharesCount: state.post!.sharesCount,
      viewsCount: state.post!.viewsCount,
      isLiked: !state.post!.isLiked,
      isBookmarked: state.post!.isBookmarked,
      commentsEnabled: state.post!.commentsEnabled,
      likesEnabled: state.post!.likesEnabled,
      sharesEnabled: state.post!.sharesEnabled,
      isPinned: state.post!.isPinned,
      createdAt: state.post!.createdAt,
      updatedAt: state.post!.updatedAt,
    );

    emit(state.copyWith(post: updatedPost));

    // Here you would call the actual API
    // await likePost(LikePostParams(postId: event.postId));
  }

  Future<void> _onBookmarkToggled(
    PostDetailBookmarkToggled event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state.post == null) return;

    // Optimistically update the UI
    final updatedPost = PostEntity(
      id: state.post!.id,
      authorId: state.post!.authorId,
      content: state.post!.content,
      contentType: state.post!.contentType,
      type: state.post!.type,
      visibility: state.post!.visibility,
      mediaUrls: state.post!.mediaUrls,
      hashtags: state.post!.hashtags,
      mentions: state.post!.mentions,
      location: state.post!.location,
      likesCount: state.post!.likesCount,
      commentsCount: state.post!.commentsCount,
      sharesCount: state.post!.sharesCount,
      viewsCount: state.post!.viewsCount,
      isLiked: state.post!.isLiked,
      isBookmarked: !state.post!.isBookmarked,
      commentsEnabled: state.post!.commentsEnabled,
      likesEnabled: state.post!.likesEnabled,
      sharesEnabled: state.post!.sharesEnabled,
      isPinned: state.post!.isPinned,
      createdAt: state.post!.createdAt,
      updatedAt: state.post!.updatedAt,
    );

    emit(state.copyWith(post: updatedPost));
  }

  Future<void> _onCommentSubmitted(
    PostDetailCommentSubmitted event,
    Emitter<PostDetailState> emit,
  ) async {
    // Here you would create the comment via API
    // For now, we'll simulate adding a comment
    final newComment = CommentModel(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: event.postId,
      authorId: 'current_user',
      content: event.content,
      contentType: 'text',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    emit(state.copyWith(
      comments: [newComment, ...state.comments],
    ));
  }

  Future<void> _onCommentLikeToggled(
    PostDetailCommentLikeToggled event,
    Emitter<PostDetailState> emit,
  ) async {
    // Toggle comment like
    final updatedComments = state.comments.map((comment) {
      if (comment.id == event.commentId) {
        return CommentModel(
          id: comment.id,
          postId: comment.postId,
          authorId: comment.authorId,
          parentCommentId: comment.parentCommentId,
          content: comment.content,
          contentType: comment.contentType,
          mentions: comment.mentions,
          likesCount:
              comment.isLiked ? comment.likesCount - 1 : comment.likesCount + 1,
          repliesCount: comment.repliesCount,
          isLiked: !comment.isLiked,
          isPinned: comment.isPinned,
          createdAt: comment.createdAt,
          updatedAt: comment.updatedAt,
        );
      }
      return comment;
    }).toList();

    emit(state.copyWith(comments: updatedComments));
  }

  Future<void> _onLoadMoreCommentsRequested(
    PostDetailLoadMoreCommentsRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state.isLoadingComments || !state.hasMoreComments) return;

    emit(state.copyWith(isLoadingComments: true));

    // Simulate loading more comments
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      isLoadingComments: false,
      hasMoreComments: false, // No more comments for demo
    ));
  }
}
