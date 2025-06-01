import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/posts_repository.dart';
import '../entities/post_entity.dart';

class UpdatePostUseCase {
  final PostsRepository repository;

  UpdatePostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(UpdatePostParams params) async {
    return await repository.updatePost(
      params.postId,
      params.toJson(),
    );
  }
}

class UpdatePostParams {
  final String postId;
  final String? content;
  final String? visibility;
  final String? location;
  final List<String>? hashtags;
  final List<String>? mentions;
  final bool? commentsEnabled;
  final bool? likesEnabled;
  final bool? sharesEnabled;
  final bool? isPinned;

  UpdatePostParams({
    required this.postId,
    this.content,
    this.visibility,
    this.location,
    this.hashtags,
    this.mentions,
    this.commentsEnabled,
    this.likesEnabled,
    this.sharesEnabled,
    this.isPinned,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (content != null) data['content'] = content;
    if (visibility != null) data['visibility'] = visibility;
    if (location != null) data['location'] = location;
    if (hashtags != null) data['hashtags'] = hashtags;
    if (mentions != null) data['mentions'] = mentions;
    if (commentsEnabled != null) data['comments_enabled'] = commentsEnabled;
    if (likesEnabled != null) data['likes_enabled'] = likesEnabled;
    if (sharesEnabled != null) data['shares_enabled'] = sharesEnabled;
    if (isPinned != null) data['is_pinned'] = isPinned;

    return data;
  }
}
