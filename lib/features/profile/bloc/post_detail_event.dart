abstract class PostDetailEvent {
  const PostDetailEvent();
}

class PostDetailLoadRequested extends PostDetailEvent {
  final String postId;
  const PostDetailLoadRequested({required this.postId});
}

class PostDetailLikeToggled extends PostDetailEvent {
  final String postId;
  const PostDetailLikeToggled({required this.postId});
}

class PostDetailBookmarkToggled extends PostDetailEvent {
  final String postId;
  const PostDetailBookmarkToggled({required this.postId});
}

class PostDetailCommentSubmitted extends PostDetailEvent {
  final String postId;
  final String content;
  const PostDetailCommentSubmitted({
    required this.postId,
    required this.content,
  });
}

class PostDetailCommentLikeToggled extends PostDetailEvent {
  final String commentId;
  const PostDetailCommentLikeToggled({required this.commentId});
}

class PostDetailLoadMoreCommentsRequested extends PostDetailEvent {
  final String postId;
  const PostDetailLoadMoreCommentsRequested({required this.postId});
}
