import 'package:vyral/features/profile/domain/entities/user_entity.dart';

class FollowersState {
  final List<UserEntity> followers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final int? totalCount;
  final int currentPage;
  final bool hasMoreData;

  const FollowersState({
    this.followers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.totalCount,
    this.currentPage = 0,
    this.hasMoreData = true,
  });

  FollowersState copyWith({
    List<UserEntity>? followers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    int? totalCount,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return FollowersState(
      followers: followers ?? this.followers,
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
