// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedModel _$FeedModelFromJson(Map<String, dynamic> json) => FeedModel(
      feedPosts: (json['posts'] as List<dynamic>)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      feedPagination:
          PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
      feedType: json['feed_type'] as String,
      lastRefreshed: DateTime.parse(json['last_refreshed'] as String),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$FeedModelToJson(FeedModel instance) => <String, dynamic>{
      'posts': instance.feedPosts,
      'pagination': instance.feedPagination,
      'feed_type': instance.feedType,
      'last_refreshed': instance.lastRefreshed.toIso8601String(),
      'has_more': instance.hasMore,
    };

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['id'] as String,
      content: json['content'] as String,
      postContentType: json['content_type'] as String,
      postType: json['post_type'] as String,
      postVisibility: json['visibility'] as String,
      postAuthor: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      postMedia: (json['media'] as List<dynamic>)
          .map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      postStats: PostStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
      postHashtags:
          (json['hashtags'] as List<dynamic>).map((e) => e as String).toList(),
      postMentions: (json['mentions'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: json['location'] as String?,
      language: json['language'] as String?,
      commentsEnabled: json['comments_enabled'] as bool,
      likesEnabled: json['likes_enabled'] as bool,
      sharesEnabled: json['shares_enabled'] as bool,
      isLiked: json['is_liked'] as bool,
      isBookmarked: json['is_bookmarked'] as bool,
      isPinned: json['is_pinned'] as bool,
      groupId: json['group_id'] as String?,
      eventId: json['event_id'] as String?,
      scheduledFor: json['scheduled_for'] == null
          ? null
          : DateTime.parse(json['scheduled_for'] as String),
      pollData: json['poll_data'] == null
          ? null
          : PollDataModel.fromJson(json['poll_data'] as Map<String, dynamic>),
      sharedPost: json['shared_post'] == null
          ? null
          : SharedPostDataModel.fromJson(
              json['shared_post'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'location': instance.location,
      'language': instance.language,
      'author': instance.postAuthor,
      'content_type': instance.postContentType,
      'post_type': instance.postType,
      'visibility': instance.postVisibility,
      'media': instance.postMedia,
      'stats': instance.postStats,
      'hashtags': instance.postHashtags,
      'mentions': instance.postMentions,
      'comments_enabled': instance.commentsEnabled,
      'likes_enabled': instance.likesEnabled,
      'shares_enabled': instance.sharesEnabled,
      'is_liked': instance.isLiked,
      'is_bookmarked': instance.isBookmarked,
      'is_pinned': instance.isPinned,
      'group_id': instance.groupId,
      'event_id': instance.eventId,
      'scheduled_for': instance.scheduledFor?.toIso8601String(),
      'poll_data': instance.pollData,
      'shared_post': instance.sharedPost,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

PostStatsModel _$PostStatsModelFromJson(Map<String, dynamic> json) =>
    PostStatsModel(
      likesCount: (json['likes_count'] as num).toInt(),
      commentsCount: (json['comments_count'] as num).toInt(),
      sharesCount: (json['shares_count'] as num).toInt(),
      viewsCount: (json['views_count'] as num).toInt(),
      bookmarksCount: (json['bookmarks_count'] as num).toInt(),
      engagementRate: (json['engagement_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$PostStatsModelToJson(PostStatsModel instance) =>
    <String, dynamic>{
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'shares_count': instance.sharesCount,
      'views_count': instance.viewsCount,
      'bookmarks_count': instance.bookmarksCount,
      'engagement_rate': instance.engagementRate,
    };

PollDataModel _$PollDataModelFromJson(Map<String, dynamic> json) =>
    PollDataModel(
      question: json['question'] as String,
      pollOptions: (json['options'] as List<dynamic>)
          .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      allowMultiple: json['allow_multiple'] as bool,
      hasVoted: json['has_voted'] as bool,
      userVote: json['user_vote'] as String?,
    );

Map<String, dynamic> _$PollDataModelToJson(PollDataModel instance) =>
    <String, dynamic>{
      'question': instance.question,
      'options': instance.pollOptions,
      'expires_at': instance.expiresAt.toIso8601String(),
      'allow_multiple': instance.allowMultiple,
      'has_voted': instance.hasVoted,
      'user_vote': instance.userVote,
    };

PollOptionModel _$PollOptionModelFromJson(Map<String, dynamic> json) =>
    PollOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      votes: (json['votes'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$PollOptionModelToJson(PollOptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'votes': instance.votes,
      'percentage': instance.percentage,
    };

SharedPostDataModel _$SharedPostDataModelFromJson(Map<String, dynamic> json) =>
    SharedPostDataModel(
      originalPost:
          PostModel.fromJson(json['original_post'] as Map<String, dynamic>),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$SharedPostDataModelToJson(
        SharedPostDataModel instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'original_post': instance.originalPost,
    };
