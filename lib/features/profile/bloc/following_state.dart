import 'package:vyral/features/profile/domain/entities/user_entity.dart';

class FollowingState {
  final List<UserEntity> following;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final int? totalCount;
  final int currentPage;
  final bool hasMoreData;

  const FollowingState({
    this.following = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.totalCount,
    this.currentPage = 0,
    this.hasMoreData = true,
  });

  FollowingState copyWith({
    List<UserEntity>? following,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    int? totalCount,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return FollowingState(
      following: following ?? this.following,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}
