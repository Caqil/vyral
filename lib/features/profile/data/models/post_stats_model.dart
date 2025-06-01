import 'package:json_annotation/json_annotation.dart';

part 'post_stats_model.g.dart';

@JsonSerializable()
class PostStatsModel {
  final String postId;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final int bookmarksCount;
  final double engagementRate;
  final Map<String, int> reactionBreakdown;
  final DateTime lastUpdated;

  const PostStatsModel({
    required this.postId,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.bookmarksCount,
    required this.engagementRate,
    required this.reactionBreakdown,
    required this.lastUpdated,
  });

  factory PostStatsModel.fromJson(Map<String, dynamic> json) {
    return PostStatsModel(
      postId: json['post_id'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      bookmarksCount: json['bookmarks_count'] as int? ?? 0,
      engagementRate: (json['engagement_rate'] as num?)?.toDouble() ?? 0.0,
      reactionBreakdown: json['reaction_breakdown'] != null
          ? Map<String, int>.from(json['reaction_breakdown'] as Map)
          : {},
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$PostStatsModelToJson(this);
}
