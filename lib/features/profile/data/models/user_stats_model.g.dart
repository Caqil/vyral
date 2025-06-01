// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) =>
    UserStatsModel(
      userId: json['userId'] as String,
      totalPosts: (json['totalPosts'] as num).toInt(),
      totalLikes: (json['totalLikes'] as num).toInt(),
      totalComments: (json['totalComments'] as num).toInt(),
      totalShares: (json['totalShares'] as num).toInt(),
      totalViews: (json['totalViews'] as num).toInt(),
      totalStories: (json['totalStories'] as num).toInt(),
      profileViews: (json['profileViews'] as num).toInt(),
      engagementRate: (json['engagementRate'] as num).toDouble(),
      weeklyGrowth: (json['weeklyGrowth'] as num).toDouble(),
      monthlyGrowth: (json['monthlyGrowth'] as num).toDouble(),
      topHashtags: Map<String, int>.from(json['topHashtags'] as Map),
      mostActiveHours: (json['mostActiveHours'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastCalculated: DateTime.parse(json['lastCalculated'] as String),
    );

Map<String, dynamic> _$UserStatsModelToJson(UserStatsModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalPosts': instance.totalPosts,
      'totalLikes': instance.totalLikes,
      'totalComments': instance.totalComments,
      'totalShares': instance.totalShares,
      'totalViews': instance.totalViews,
      'totalStories': instance.totalStories,
      'profileViews': instance.profileViews,
      'engagementRate': instance.engagementRate,
      'weeklyGrowth': instance.weeklyGrowth,
      'monthlyGrowth': instance.monthlyGrowth,
      'topHashtags': instance.topHashtags,
      'mostActiveHours': instance.mostActiveHours,
      'lastCalculated': instance.lastCalculated.toIso8601String(),
    };
