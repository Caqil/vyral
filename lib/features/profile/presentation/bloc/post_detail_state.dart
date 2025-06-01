import '../../data/models/comment_model.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/user_entity.dart';

class PostDetailState {
  final PostEntity? post;
  final UserEntity? author;
  final List<CommentModel> comments;
  final bool isLoading;
  final bool isLoadingComments;
  final bool hasError;
  final String? errorMessage;
  final int commentsPage;
  final bool hasMoreComments;

  const PostDetailState({
    this.post,
    this.author,
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingComments = false,
    this.hasError = false,
    this.errorMessage,
    this.commentsPage = 0,
    this.hasMoreComments = true,
  });

  PostDetailState copyWith({
    PostEntity? post,
    UserEntity? author,
    List<CommentModel>? comments,
    bool? isLoading,
    bool? isLoadingComments,
    bool? hasError,
    String? errorMessage,
    int? commentsPage,
    bool? hasMoreComments,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      author: author ?? this.author,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      commentsPage: commentsPage ?? this.commentsPage,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
    );
  }
}
