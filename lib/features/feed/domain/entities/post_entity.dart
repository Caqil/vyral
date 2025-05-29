// lib/features/feed/domain/entities/post_entity.dart
import 'package:equatable/equatable.dart';
import '../../../../shared/models/media_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

enum PostType { regular, story, poll, event, shared }

enum PostVisibility { public, friends, private }

enum ContentType { text, image, video, link, poll }

class PostEntity extends Equatable {
  final String id;
  final String content;
  final ContentType contentType;
  final PostType type;
  final PostVisibility visibility;
  final UserEntity author;
  final List<MediaModel> media;
  final PostStats stats;
  final List<String> hashtags;
  final List<UserEntity> mentions;
  final String? location;
  final String? language;
  final bool commentsEnabled;
  final bool likesEnabled;
  final bool sharesEnabled;
  final bool isLiked;
  final bool isBookmarked;
  final bool isPinned;
  final String? groupId;
  final String? eventId;
  final DateTime? scheduledFor;
  final PollData? pollData;
  final SharedPostData? sharedPost;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    required this.content,
    required this.contentType,
    required this.type,
    required this.visibility,
    required this.author,
    required this.media,
    required this.stats,
    required this.hashtags,
    required this.mentions,
    this.location,
    this.language,
    required this.commentsEnabled,
    required this.likesEnabled,
    required this.sharesEnabled,
    required this.isLiked,
    required this.isBookmarked,
    required this.isPinned,
    this.groupId,
    this.eventId,
    this.scheduledFor,
    this.pollData,
    this.sharedPost,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        contentType,
        type,
        visibility,
        author,
        media,
        stats,
        hashtags,
        mentions,
        location,
        language,
        commentsEnabled,
        likesEnabled,
        sharesEnabled,
        isLiked,
        isBookmarked,
        isPinned,
        groupId,
        eventId,
        scheduledFor,
        pollData,
        sharedPost,
        createdAt,
        updatedAt,
      ];

  PostEntity copyWith({
    String? id,
    String? content,
    ContentType? contentType,
    PostType? type,
    PostVisibility? visibility,
    UserEntity? author,
    List<MediaModel>? media,
    PostStats? stats,
    List<String>? hashtags,
    List<UserEntity>? mentions,
    String? location,
    String? language,
    bool? commentsEnabled,
    bool? likesEnabled,
    bool? sharesEnabled,
    bool? isLiked,
    bool? isBookmarked,
    bool? isPinned,
    String? groupId,
    String? eventId,
    DateTime? scheduledFor,
    PollData? pollData,
    SharedPostData? sharedPost,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
      author: author ?? this.author,
      media: media ?? this.media,
      stats: stats ?? this.stats,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      location: location ?? this.location,
      language: language ?? this.language,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      likesEnabled: likesEnabled ?? this.likesEnabled,
      sharesEnabled: sharesEnabled ?? this.sharesEnabled,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isPinned: isPinned ?? this.isPinned,
      groupId: groupId ?? this.groupId,
      eventId: eventId ?? this.eventId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      pollData: pollData ?? this.pollData,
      sharedPost: sharedPost ?? this.sharedPost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasMedia => media.isNotEmpty;
  bool get isPoll => type == PostType.poll && pollData != null;
  bool get isShared => type == PostType.shared && sharedPost != null;
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class PostStats extends Equatable {
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final int bookmarksCount;
  final double engagementRate;

  const PostStats({
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.bookmarksCount,
    required this.engagementRate,
  });

  @override
  List<Object?> get props => [
        likesCount,
        commentsCount,
        sharesCount,
        viewsCount,
        bookmarksCount,
        engagementRate,
      ];

  PostStats copyWith({
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    int? bookmarksCount,
    double? engagementRate,
  }) {
    return PostStats(
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      engagementRate: engagementRate ?? this.engagementRate,
    );
  }

  int get totalInteractions => likesCount + commentsCount + sharesCount;
}

class PollData extends Equatable {
  final String question;
  final List<PollOption> options;
  final DateTime expiresAt;
  final bool allowMultiple;
  final bool hasVoted;
  final String? userVote;

  const PollData({
    required this.question,
    required this.options,
    required this.expiresAt,
    required this.allowMultiple,
    required this.hasVoted,
    this.userVote,
  });

  @override
  List<Object?> get props => [
        question,
        options,
        expiresAt,
        allowMultiple,
        hasVoted,
        userVote,
      ];

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get totalVotes => options.fold(0, (sum, option) => sum + option.votes);
}

class PollOption extends Equatable {
  final String id;
  final String text;
  final int votes;
  final double percentage;

  const PollOption({
    required this.id,
    required this.text,
    required this.votes,
    required this.percentage,
  });

  @override
  List<Object?> get props => [id, text, votes, percentage];
}

class SharedPostData extends Equatable {
  final PostEntity originalPost;
  final String? comment;

  const SharedPostData({
    required this.originalPost,
    this.comment,
  });

  @override
  List<Object?> get props => [originalPost, comment];
}
