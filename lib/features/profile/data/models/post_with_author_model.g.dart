// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_with_author_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostWithAuthorModel _$PostWithAuthorModelFromJson(Map<String, dynamic> json) =>
    PostWithAuthorModel(
      postModel: PostModel.fromJson(json['post'] as Map<String, dynamic>),
      authorModel: UserModel.fromJson(json['author'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostWithAuthorModelToJson(
        PostWithAuthorModel instance) =>
    <String, dynamic>{
      'post': instance.postModel,
      'author': instance.authorModel,
    };
