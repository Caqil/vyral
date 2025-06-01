import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post_with_author_entity.dart';
import '../../../profile/data/models/user_model.dart';
import 'post_model.dart';

part 'post_with_author_model.g.dart';

@JsonSerializable()
class PostWithAuthorModel extends PostWithAuthorEntity {
  const PostWithAuthorModel({
    required PostModel post,
    required UserModel author,
  }) : super(post: post, author: author);

  factory PostWithAuthorModel.fromJson(Map<String, dynamic> json) {
    return PostWithAuthorModel(
      post: PostModel.fromJson(json['post'] as Map<String, dynamic>),
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => _$PostWithAuthorModelToJson(this);
}
