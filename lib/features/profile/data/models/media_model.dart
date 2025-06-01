import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/media_entity.dart';

part 'media_model.g.dart';

@JsonSerializable()
class MediaModel extends MediaEntity {
  const MediaModel({
    required super.id,
    required super.userId,
    required super.url,
    required super.type,
    super.mimeType,
    super.size,
    super.width,
    super.height,
    super.duration,
    super.altText,
    super.description,
    super.thumbnailUrl,
    super.isPublic,
    super.relatedTo,
    super.relatedId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      mimeType: json['mime_type'] as String?,
      size: json['size'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      altText: json['alt_text'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      relatedTo: json['related_to'] as String?,
      relatedId: json['related_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$MediaModelToJson(this);
}
