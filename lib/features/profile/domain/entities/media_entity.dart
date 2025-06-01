import 'package:equatable/equatable.dart';

class MediaEntity extends Equatable {
  final String id;
  final String userId;
  final String url;
  final String type;
  final String? mimeType;
  final int? size;
  final int? width;
  final int? height;
  final int? duration;
  final String? altText;
  final String? description;
  final String? thumbnailUrl;
  final bool isPublic;
  final String? relatedTo;
  final String? relatedId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MediaEntity({
    required this.id,
    required this.userId,
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
    this.isPublic = true,
    this.relatedTo,
    this.relatedId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        url,
        type,
        mimeType,
        size,
        width,
        height,
        duration,
        altText,
        description,
        thumbnailUrl,
        isPublic,
        relatedTo,
        relatedId,
        createdAt,
        updatedAt,
      ];

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';
  bool get isDocument => type == 'document';

  String get displayUrl => thumbnailUrl ?? url;
}
