import 'package:dartz/dartz.dart';
import 'package:vyral/features/profile/domain/entities/user_entity.dart';

import '../../../../core/error/failures.dart';
import '../entities/follow_status_entity.dart';
import '../entities/media_entity.dart';
import '../entities/post_entity.dart';
import '../entities/story_highlight_entity.dart';
import '../entities/user_stats_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getUserProfile(String userId);
  Future<Either<Failure, UserEntity>> getUserByUsername(String username);
  Future<Either<Failure, UserStatsEntity>> getUserStats(String userId);
  Future<Either<Failure, FollowStatusEntity>> getFollowStatus(String userId);
  Future<Either<Failure, FollowStatusEntity>> followUser(String userId);
  Future<Either<Failure, FollowStatusEntity>> unfollowUser(String userId);
  Future<Either<Failure, List<PostEntity>>> getUserPosts(
      String userId, int page, int limit);
  Future<Either<Failure, List<MediaEntity>>> getUserMedia(
      String userId, int page, int limit,
      {String? type});
  Future<Either<Failure, List<StoryHighlightEntity>>> getUserHighlights(
      String userId);
  Future<Either<Failure, List<UserEntity>>> getFollowers(
      String userId, int page, int limit);
  Future<Either<Failure, List<UserEntity>>> getFollowing(
      String userId, int page, int limit);
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> data);
}
