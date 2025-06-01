// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_with_author_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentWithAuthorModel _$CommentWithAuthorModelFromJson(
        Map<String, dynamic> json) =>
    CommentWithAuthorModel(
      commentModel:
          CommentModel.fromJson(json['comment'] as Map<String, dynamic>),
      authorModel: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      replyModels: (json['replies'] as List<dynamic>?)
              ?.map((e) =>
                  CommentWithAuthorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CommentWithAuthorModelToJson(
        CommentWithAuthorModel instance) =>
    <String, dynamic>{
      'comment': instance.commentModel,
      'author': instance.authorModel,
      'replies': instance.replyModels,
    };
