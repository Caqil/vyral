// lib/features/feed/data/models/feed_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/models/media_model.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/feed_entity.dart';
import '../../../../shared/models/pagination_model.dart';
import '../../domain/entities/post_entity.dart';

part 'feed_model.g.dart';

@JsonSerializable()
class FeedModel extends FeedEntity {
  @JsonKey(name: 'posts')
  final List<PostModel> feedPosts;
  @JsonKey(name: 'pagination')
  final PaginationModel feedPagination;
  @JsonKey(name: 'feed_type')
  final String feedType;
  @JsonKey(name: 'last_refreshed')
  final DateTime lastRefreshed;
  @JsonKey(name: 'has_more')
  final bool hasMore;

  const FeedModel({
    required this.feedPosts,
    required this.feedPagination,
    required this.feedType,
    required this.lastRefreshed,
    required this.hasMore,
  }) : super(
          posts: feedPosts,
          pagination: feedPagination,
          feedType: feedType,
          lastRefreshed: lastRefreshed,
          hasMore: hasMore,
        );

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    try {
      return FeedModel(
        feedPosts: (json['posts'] as List? ?? [])
            .map((post) => PostModel.fromJson(post as Map<String, dynamic>))
            .toList(),
        feedPagination: json['pagination'] != null
            ? PaginationModel.fromJson(
                json['pagination'] as Map<String, dynamic>)
            : const PaginationModel(),
        feedType: json['feed_type']?.toString() ?? 'personal',
        lastRefreshed: json['last_refreshed'] != null
            ? DateTime.parse(json['last_refreshed'].toString())
            : DateTime.now(),
        hasMore: json['has_more'] as bool? ?? false,
      );
    } catch (e) {
      throw FormatException('Failed to parse feed data: $e');
    }
  }

  Map<String, dynamic> toJson() => _$FeedModelToJson(this);

  factory FeedModel.fromEntity(FeedEntity entity) {
    return FeedModel(
      feedPosts:
          entity.posts.map((post) => PostModel.fromEntity(post)).toList(),
      feedPagination: entity.pagination,
      feedType: entity.feedType,
      lastRefreshed: entity.lastRefreshed,
      hasMore: entity.hasMore,
    );
  }
}

// lib/features/feed/data/models/post_model.dart
@JsonSerializable()
class PostModel extends PostEntity {
  @JsonKey(name: 'author')
  final UserModel postAuthor;
  @JsonKey(name: 'content_type')
  final String postContentType;
  @JsonKey(name: 'post_type')
  final String postType;
  @JsonKey(name: 'visibility')
  final String postVisibility;
  @JsonKey(name: 'media')
  final List<MediaModel> postMedia;
  @JsonKey(name: 'stats')
  final PostStatsModel postStats;
  @JsonKey(name: 'hashtags')
  final List<String> postHashtags;
  @JsonKey(name: 'mentions')
  final List<UserModel> postMentions;
  @JsonKey(name: 'comments_enabled')
  final bool commentsEnabled;
  @JsonKey(name: 'likes_enabled')
  final bool likesEnabled;
  @JsonKey(name: 'shares_enabled')
  final bool sharesEnabled;
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  @JsonKey(name: 'is_bookmarked')
  final bool isBookmarked;
  @JsonKey(name: 'is_pinned')
  final bool isPinned;
  @JsonKey(name: 'group_id')
  final String? groupId;
  @JsonKey(name: 'event_id')
  final String? eventId;
  @JsonKey(name: 'scheduled_for')
  final DateTime? scheduledFor;
  @JsonKey(name: 'poll_data')
  final PollDataModel? pollData;
  @JsonKey(name: 'shared_post')
  final SharedPostDataModel? sharedPost;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

   PostModel({
    required super.id,
    required super.content,
    required this.postContentType,
    required this.postType,
    required this.postVisibility,
    required this.postAuthor,
    required this.postMedia,
    required this.postStats,
    required this.postHashtags,
    required this.postMentions,
    super.location,
    super.language,
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
  }) : super(
          contentType: _parseContentType(postContentType),
          type: _parsePostType(postType),
          visibility: _parseVisibility(postVisibility),
          author: postAuthor,
          media: postMedia,
          stats: postStats,
          hashtags: postHashtags,
          mentions: postMentions,
          commentsEnabled: commentsEnabled,
          likesEnabled: likesEnabled,
          sharesEnabled: sharesEnabled,
          isLiked: isLiked,
          isBookmarked: isBookmarked,
          isPinned: isPinned,
          groupId: groupId,
          eventId: eventId,
          scheduledFor: scheduledFor,
          pollData: pollData,
          sharedPost: sharedPost,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      return PostModel(
        id: json['id']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        postContentType: json['content_type']?.toString() ?? 'text',
        postType: json['post_type']?.toString() ??
            json['type']?.toString() ??
            'regular',
        postVisibility: json['visibility']?.toString() ?? 'public',
        postAuthor:
            UserModel.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
        postMedia: (json['media'] as List? ?? [])
            .map((media) => MediaModel.fromJson(media as Map<String, dynamic>))
            .toList(),
        postStats: PostStatsModel.fromJson(
            json['stats'] as Map<String, dynamic>? ?? {}),
        postHashtags: (json['hashtags'] as List? ?? [])
            .map((tag) => tag.toString())
            .toList(),
        postMentions: (json['mentions'] as List? ?? [])
            .map((mention) =>
                UserModel.fromJson(mention as Map<String, dynamic>))
            .toList(),
        location: json['location']?.toString(),
        language: json['language']?.toString() ?? 'en',
        commentsEnabled: json['comments_enabled'] as bool? ?? true,
        likesEnabled: json['likes_enabled'] as bool? ?? true,
        sharesEnabled: json['shares_enabled'] as bool? ?? true,
        isLiked: json['is_liked'] as bool? ?? false,
        isBookmarked: json['is_bookmarked'] as bool? ?? false,
        isPinned: json['is_pinned'] as bool? ?? false,
        groupId: json['group_id']?.toString(),
        eventId: json['event_id']?.toString(),
        scheduledFor: json['scheduled_for'] != null
            ? DateTime.parse(json['scheduled_for'].toString())
            : null,
        pollData: json['poll_data'] != null
            ? PollDataModel.fromJson(json['poll_data'] as Map<String, dynamic>)
            : null,
        sharedPost: json['shared_post'] != null
            ? SharedPostDataModel.fromJson(
                json['shared_post'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(
            json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      throw FormatException('Failed to parse post data: $e');
    }
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      content: entity.content,
      postContentType: _contentTypeToString(entity.contentType),
      postType: _postTypeToString(entity.type),
      postVisibility: _visibilityToString(entity.visibility),
      postAuthor: UserModel.fromEntity(entity.author),
      postMedia: entity.media,
      postStats: PostStatsModel.fromEntity(entity.stats),
      postHashtags: entity.hashtags,
      postMentions:
          entity.mentions.map((user) => UserModel.fromEntity(user)).toList(),
      location: entity.location,
      language: entity.language,
      commentsEnabled: entity.commentsEnabled,
      likesEnabled: entity.likesEnabled,
      sharesEnabled: entity.sharesEnabled,
      isLiked: entity.isLiked,
      isBookmarked: entity.isBookmarked,
      isPinned: entity.isPinned,
      groupId: entity.groupId,
      eventId: entity.eventId,
      scheduledFor: entity.scheduledFor,
      pollData: entity.pollData != null
          ? PollDataModel.fromEntity(entity.pollData!)
          : null,
      sharedPost: entity.sharedPost != null
          ? SharedPostDataModel.fromEntity(entity.sharedPost!)
          : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static ContentType _parseContentType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return ContentType.image;
      case 'video':
        return ContentType.video;
      case 'link':
        return ContentType.link;
      case 'poll':
        return ContentType.poll;
      default:
        return ContentType.text;
    }
  }

  static PostType _parsePostType(String type) {
    switch (type.toLowerCase()) {
      case 'story':
        return PostType.story;
      case 'poll':
        return PostType.poll;
      case 'event':
        return PostType.event;
      case 'shared':
        return PostType.shared;
      default:
        return PostType.regular;
    }
  }

  static PostVisibility _parseVisibility(String visibility) {
    switch (visibility.toLowerCase()) {
      case 'friends':
        return PostVisibility.friends;
      case 'private':
        return PostVisibility.private;
      default:
        return PostVisibility.public;
    }
  }

  static String _contentTypeToString(ContentType type) {
    switch (type) {
      case ContentType.image:
        return 'image';
      case ContentType.video:
        return 'video';
      case ContentType.link:
        return 'link';
      case ContentType.poll:
        return 'poll';
      default:
        return 'text';
    }
  }

  static String _postTypeToString(PostType type) {
    switch (type) {
      case PostType.story:
        return 'story';
      case PostType.poll:
        return 'poll';
      case PostType.event:
        return 'event';
      case PostType.shared:
        return 'shared';
      default:
        return 'regular';
    }
  }

  static String _visibilityToString(PostVisibility visibility) {
    switch (visibility) {
      case PostVisibility.friends:
        return 'friends';
      case PostVisibility.private:
        return 'private';
      default:
        return 'public';
    }
  }
}

@JsonSerializable()
class PostStatsModel extends PostStats {
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  @JsonKey(name: 'shares_count')
  final int sharesCount;
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'bookmarks_count')
  final int bookmarksCount;
  @JsonKey(name: 'engagement_rate')
  final double engagementRate;

  const PostStatsModel({
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.bookmarksCount,
    required this.engagementRate,
  }) : super(
          likesCount: likesCount,
          commentsCount: commentsCount,
          sharesCount: sharesCount,
          viewsCount: viewsCount,
          bookmarksCount: bookmarksCount,
          engagementRate: engagementRate,
        );

  factory PostStatsModel.fromJson(Map<String, dynamic> json) {
    return PostStatsModel(
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      sharesCount: (json['shares_count'] as num?)?.toInt() ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      bookmarksCount: (json['bookmarks_count'] as num?)?.toInt() ?? 0,
      engagementRate: (json['engagement_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => _$PostStatsModelToJson(this);

  factory PostStatsModel.fromEntity(PostStats entity) {
    return PostStatsModel(
      likesCount: entity.likesCount,
      commentsCount: entity.commentsCount,
      sharesCount: entity.sharesCount,
      viewsCount: entity.viewsCount,
      bookmarksCount: entity.bookmarksCount,
      engagementRate: entity.engagementRate,
    );
  }
}

@JsonSerializable()
class PollDataModel extends PollData {
  @JsonKey(name: 'options')
  final List<PollOptionModel> pollOptions;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @JsonKey(name: 'allow_multiple')
  final bool allowMultiple;
  @JsonKey(name: 'has_voted')
  final bool hasVoted;
  @JsonKey(name: 'user_vote')
  final String? userVote;

  const PollDataModel({
    required String question,
    required this.pollOptions,
    required this.expiresAt,
    required this.allowMultiple,
    required this.hasVoted,
    this.userVote,
  }) : super(
          question: question,
          options: pollOptions,
          expiresAt: expiresAt,
          allowMultiple: allowMultiple,
          hasVoted: hasVoted,
          userVote: userVote,
        );

  factory PollDataModel.fromJson(Map<String, dynamic> json) {
    return PollDataModel(
      question: json['question']?.toString() ?? '',
      pollOptions: (json['options'] as List? ?? [])
          .map((option) =>
              PollOptionModel.fromJson(option as Map<String, dynamic>))
          .toList(),
      expiresAt: DateTime.parse(json['expires_at']?.toString() ??
          DateTime.now().add(const Duration(days: 7)).toIso8601String()),
      allowMultiple: json['allow_multiple'] as bool? ?? false,
      hasVoted: json['has_voted'] as bool? ?? false,
      userVote: json['user_vote']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$PollDataModelToJson(this);

  factory PollDataModel.fromEntity(PollData entity) {
    return PollDataModel(
      question: entity.question,
      pollOptions: entity.options
          .map((option) => PollOptionModel.fromEntity(option))
          .toList(),
      expiresAt: entity.expiresAt,
      allowMultiple: entity.allowMultiple,
      hasVoted: entity.hasVoted,
      userVote: entity.userVote,
    );
  }
}

@JsonSerializable()
class PollOptionModel extends PollOption {
  const PollOptionModel({
    required String id,
    required String text,
    required int votes,
    required double percentage,
  }) : super(
          id: id,
          text: text,
          votes: votes,
          percentage: percentage,
        );

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      votes: (json['votes'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => _$PollOptionModelToJson(this);

  factory PollOptionModel.fromEntity(PollOption entity) {
    return PollOptionModel(
      id: entity.id,
      text: entity.text,
      votes: entity.votes,
      percentage: entity.percentage,
    );
  }
}

@JsonSerializable()
class SharedPostDataModel extends SharedPostData {
  @JsonKey(name: 'original_post')
  final PostModel originalPost;

  const SharedPostDataModel({
    required this.originalPost,
    String? comment,
  }) : super(
          originalPost: originalPost,
          comment: comment,
        );

  factory SharedPostDataModel.fromJson(Map<String, dynamic> json) {
    return SharedPostDataModel(
      originalPost:
          PostModel.fromJson(json['original_post'] as Map<String, dynamic>),
      comment: json['comment']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$SharedPostDataModelToJson(this);

  factory SharedPostDataModel.fromEntity(SharedPostData entity) {
    return SharedPostDataModel(
      originalPost: PostModel.fromEntity(entity.originalPost),
      comment: entity.comment,
    );
  }
}
