import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String authorId;
  final String content;
  final String contentType;
  final String type;
  final String visibility;
  final List<String> mediaUrls;
  final List<String> hashtags;
  final List<String> mentions;
  final String? location;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isLiked;
  final bool isBookmarked;
  final bool commentsEnabled;
  final bool likesEnabled;
  final bool sharesEnabled;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    required this.authorId,
    required this.content,
    required this.contentType,
    required this.type,
    required this.visibility,
    this.mediaUrls = const [],
    this.hashtags = const [],
    this.mentions = const [],
    this.location,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.commentsEnabled = true,
    this.likesEnabled = true,
    this.sharesEnabled = true,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        authorId,
        content,
        contentType,
        type,
        visibility,
        mediaUrls,
        hashtags,
        mentions,
        location,
        likesCount,
        commentsCount,
        sharesCount,
        viewsCount,
        isLiked,
        isBookmarked,
        commentsEnabled,
        likesEnabled,
        sharesEnabled,
        isPinned,
        createdAt,
        updatedAt,
      ];

  bool get hasMedia => mediaUrls.isNotEmpty;
  bool get isTextOnly => contentType == 'text' && !hasMedia;
  bool get isImagePost =>
      hasMedia &&
      mediaUrls.any((url) =>
          url.toLowerCase().contains('.jpg') ||
          url.toLowerCase().contains('.jpeg') ||
          url.toLowerCase().contains('.png') ||
          url.toLowerCase().contains('.gif'));
  bool get isVideoPost =>
      hasMedia &&
      mediaUrls.any((url) =>
          url.toLowerCase().contains('.mp4') ||
          url.toLowerCase().contains('.mov') ||
          url.toLowerCase().contains('.avi'));
}
