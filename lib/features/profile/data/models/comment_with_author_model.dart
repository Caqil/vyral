import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/comment_with_author_entity.dart';
import '../../../profile/data/models/user_model.dart';
import 'comment_model.dart';

part 'comment_with_author_model.g.dart';

@JsonSerializable()
class CommentWithAuthorModel extends CommentWithAuthorEntity {
  @JsonKey(name: 'comment')
  final CommentModel commentModel;

  @JsonKey(name: 'author')
  final UserModel authorModel;

  @JsonKey(name: 'replies')
  final List<CommentWithAuthorModel> replyModels;

  const CommentWithAuthorModel({
    required this.commentModel,
    required this.authorModel,
    this.replyModels = const [],
  }) : super(
          comment: commentModel,
          author: authorModel,
          replies: replyModels,
        );

  factory CommentWithAuthorModel.fromJson(Map<String, dynamic> json) {
    return CommentWithAuthorModel(
      commentModel:
          CommentModel.fromJson(json['comment'] as Map<String, dynamic>),
      authorModel: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      replyModels: json['replies'] != null
          ? (json['replies'] as List)
              .map((reply) => CommentWithAuthorModel.fromJson(
                  reply as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => _$CommentWithAuthorModelToJson(this);
}
