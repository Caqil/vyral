import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_stats_entity.dart';
part 'user_stats_model.g.dart';

@JsonSerializable()
class UserStatsModel extends UserStatsEntity {
  const UserStatsModel({
    required super.userId,
    required super.totalPosts,
    required super.totalLikes,
    required super.totalComments,
    required super.totalShares,
    required super.totalViews,
    required super.totalStories,
    required super.profileViews,
    required super.engagementRate,
    required super.weeklyGrowth,
    required super.monthlyGrowth,
    required super.topHashtags,
    required super.mostActiveHours,
    required super.lastCalculated,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['user_id'] as String,
      totalPosts: json['total_posts'] as int? ?? 0,
      totalLikes: json['total_likes'] as int? ?? 0,
      totalComments: json['total_comments'] as int? ?? 0,
      totalShares: json['total_shares'] as int? ?? 0,
      totalViews: json['total_views'] as int? ?? 0,
      totalStories: json['total_stories'] as int? ?? 0,
      profileViews: json['profile_views'] as int? ?? 0,
      engagementRate: (json['engagement_rate'] as num?)?.toDouble() ?? 0.0,
      weeklyGrowth: (json['weekly_growth'] as num?)?.toDouble() ?? 0.0,
      monthlyGrowth: (json['monthly_growth'] as num?)?.toDouble() ?? 0.0,
      topHashtags: json['top_hashtags'] != null
          ? Map<String, int>.from(json['top_hashtags'] as Map)
          : {},
      mostActiveHours: json['most_active_hours'] != null
          ? List<String>.from(json['most_active_hours'] as List)
          : [],
      lastCalculated: DateTime.parse(json['last_calculated'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$UserStatsModelToJson(this);
}
