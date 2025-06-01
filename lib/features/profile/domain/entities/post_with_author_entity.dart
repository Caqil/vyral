import 'package:equatable/equatable.dart';
import 'package:vyral/features/profile/domain/entities/post_entity.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';


class PostWithAuthorEntity extends Equatable {
  final PostEntity post;
  final UserEntity author;

  const PostWithAuthorEntity({
    required this.post,
    required this.author,
  });

  @override
  List<Object?> get props => [post, author];
}
