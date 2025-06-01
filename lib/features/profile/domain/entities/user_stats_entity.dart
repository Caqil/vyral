import 'package:equatable/equatable.dart';

class UserStatsEntity extends Equatable {
  final String userId;
  final int totalPosts;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalViews;
  final int totalStories;
  final int profileViews;
  final double engagementRate;
  final double weeklyGrowth;
  final double monthlyGrowth;
  final Map<String, int> topHashtags;
  final List<String> mostActiveHours;
  final DateTime lastCalculated;

  const UserStatsEntity({
    required this.userId,
    required this.totalPosts,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.totalViews,
    required this.totalStories,
    required this.profileViews,
    required this.engagementRate,
    required this.weeklyGrowth,
    required this.monthlyGrowth,
    required this.topHashtags,
    required this.mostActiveHours,
    required this.lastCalculated,
  });

  @override
  List<Object?> get props => [
        userId,
        totalPosts,
        totalLikes,
        totalComments,
        totalShares,
        totalViews,
        totalStories,
        profileViews,
        engagementRate,
        weeklyGrowth,
        monthlyGrowth,
        topHashtags,
        mostActiveHours,
        lastCalculated,
      ];
}
