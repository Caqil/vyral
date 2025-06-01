import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/comment_with_author_entity.dart';
import '../../../profile/data/models/user_model.dart';
import 'comment_model.dart';

part 'comment_with_author_model.g.dart';

@JsonSerializable()
class CommentWithAuthorModel extends CommentWithAuthorEntity {
  const CommentWithAuthorModel({
    required CommentModel comment,
    required UserModel author,
    List<CommentWithAuthorModel> replies = const [],
  }) : super(comment: comment, author: author, replies: replies);

  factory CommentWithAuthorModel.fromJson(Map<String, dynamic> json) {
    return CommentWithAuthorModel(
      comment: CommentModel.fromJson(json['comment'] as Map<String, dynamic>),
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((reply) => CommentWithAuthorModel.fromJson(
                  reply as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => _$CommentWithAuthorModelToJson(this);
}
