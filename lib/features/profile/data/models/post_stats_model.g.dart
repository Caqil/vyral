// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostStatsModel _$PostStatsModelFromJson(Map<String, dynamic> json) =>
    PostStatsModel(
      postId: json['postId'] as String,
      likesCount: (json['likesCount'] as num).toInt(),
      commentsCount: (json['commentsCount'] as num).toInt(),
      sharesCount: (json['sharesCount'] as num).toInt(),
      viewsCount: (json['viewsCount'] as num).toInt(),
      bookmarksCount: (json['bookmarksCount'] as num).toInt(),
      engagementRate: (json['engagementRate'] as num).toDouble(),
      reactionBreakdown:
          Map<String, int>.from(json['reactionBreakdown'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$PostStatsModelToJson(PostStatsModel instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'sharesCount': instance.sharesCount,
      'viewsCount': instance.viewsCount,
      'bookmarksCount': instance.bookmarksCount,
      'engagementRate': instance.engagementRate,
      'reactionBreakdown': instance.reactionBreakdown,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
