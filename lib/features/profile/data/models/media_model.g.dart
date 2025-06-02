// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaModel _$MediaModelFromJson(Map<String, dynamic> json) => MediaModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      mimeType: json['mimeType'] as String?,
      size: (json['size'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      altText: json['altText'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      relatedTo: json['relatedTo'] as String?,
      relatedId: json['relatedId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MediaModelToJson(MediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'url': instance.url,
      'type': instance.type,
      'mimeType': instance.mimeType,
      'size': instance.size,
      'width': instance.width,
      'height': instance.height,
      'duration': instance.duration,
      'altText': instance.altText,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'isPublic': instance.isPublic,
      'relatedTo': instance.relatedTo,
      'relatedId': instance.relatedId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
