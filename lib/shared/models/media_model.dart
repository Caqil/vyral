import 'package:json_annotation/json_annotation.dart';

part 'media_model.g.dart';

@JsonSerializable()
class MediaModel {
  final String? id;
  final String url;
  final String type; // image, video, audio, document
  @JsonKey(name: 'mime_type')
  final String? mimeType;
  final int? size;
  final int? width;
  final int? height;
  final int? duration;
  @JsonKey(name: 'alt_text')
  final String? altText;
  final String? description;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'is_public')
  final bool? isPublic;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const MediaModel({
    this.id,
    required this.url,
    required this.type,
    this.mimeType,
    this.size,
    this.width,
    this.height,
    this.duration,
    this.altText,
    this.description,
    this.thumbnailUrl,
    this.isPublic,
    this.createdAt,
    this.updatedAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) =>
      _$MediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MediaModelToJson(this);

  MediaModel copyWith({
    String? id,
    String? url,
    String? type,
    String? mimeType,
    int? size,
    int? width,
    int? height,
    int? duration,
    String? altText,
    String? description,
    String? thumbnailUrl,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaModel(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      altText: altText ?? this.altText,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';
  bool get isDocument => type == 'document';
}
