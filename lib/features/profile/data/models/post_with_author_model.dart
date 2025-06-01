import 'package:json_annotation/json_annotation.dart';
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
    return PostWithAuthorModel(
      postModel: PostModel.fromJson(json['post'] as Map<String, dynamic>),
      authorModel: UserModel.fromJson(json['author'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => _$PostWithAuthorModelToJson(this);
}
