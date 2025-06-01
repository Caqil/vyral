import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/media_entity.dart';

part 'media_model.g.dart';

@JsonSerializable()
class MediaModel extends MediaEntity {
  const MediaModel({
    required super.id,
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
    required super.createdAt,
    required super.updatedAt,
    required String userId,
    String? relatedTo,
    String? relatedId,
  }) : super(
          userId: userId,
          relatedTo: relatedTo,
          relatedId: relatedId,
        );

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String? ?? '',
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
      userId: json['user_id'] as String? ?? '',
      relatedTo: json['related_to'] as String?,
      relatedId: json['related_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$MediaModelToJson(this);
}
