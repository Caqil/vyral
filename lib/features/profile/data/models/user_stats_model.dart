// lib/features/profile/data/models/user_stats_model.dart
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
      // Handle missing user_id by using empty string as default
      userId: json['user_id'] as String? ?? '',

      // Map API field names to model field names
      totalPosts: json['posts_count'] as int? ?? 0,
      totalLikes: json['likes_count'] as int? ?? 0,
      totalComments: json['comments_count'] as int? ?? 0,
      totalShares: json['shares_count'] as int? ?? 0,
      totalViews: json['views_count'] as int? ?? 0,

      // These fields might not be in the API response, so provide defaults
      totalStories: json['stories_count'] as int? ?? 0,
      profileViews: json['profile_views'] as int? ?? 0,
      engagementRate: (json['engagement_rate'] as num?)?.toDouble() ?? 0.0,
      weeklyGrowth: (json['weekly_growth'] as num?)?.toDouble() ?? 0.0,
      monthlyGrowth: (json['monthly_growth'] as num?)?.toDouble() ?? 0.0,

      // Handle missing complex fields
      topHashtags: json['top_hashtags'] != null
          ? Map<String, int>.from(json['top_hashtags'] as Map)
          : {},
      mostActiveHours: json['most_active_hours'] != null
          ? List<String>.from(json['most_active_hours'] as List)
          : [],

      // Handle missing timestamp
      lastCalculated: json['last_calculated'] != null
          ? DateTime.parse(json['last_calculated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$UserStatsModelToJson(this);
}
