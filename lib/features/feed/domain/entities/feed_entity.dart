// lib/features/feed/domain/entities/feed_entity.dart
import 'package:equatable/equatable.dart';
import '../../../../shared/models/pagination_model.dart';
import 'post_entity.dart';

class FeedEntity extends Equatable {
  final List<PostEntity> posts;
  final PaginationModel pagination;
  final String feedType;
  final DateTime lastRefreshed;
  final bool hasMore;

  const FeedEntity({
    required this.posts,
    required this.pagination,
    required this.feedType,
    required this.lastRefreshed,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
        posts,
        pagination,
        feedType,
        lastRefreshed,
        hasMore,
      ];

  FeedEntity copyWith({
    List<PostEntity>? posts,
    PaginationModel? pagination,
    String? feedType,
    DateTime? lastRefreshed,
    bool? hasMore,
  }) {
    return FeedEntity(
      posts: posts ?? this.posts,
      pagination: pagination ?? this.pagination,
      feedType: feedType ?? this.feedType,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
