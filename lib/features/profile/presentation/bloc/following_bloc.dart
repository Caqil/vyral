import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/features/profile/presentation/bloc/following_event.dart';
import 'package:vyral/features/profile/presentation/bloc/following_state.dart';

import '../../domain/usecases/get_following_usecase.dart';
import '../../domain/usecases/unfollow_user_usecase.dart';

class FollowingBloc extends Bloc<FollowingEvent, FollowingState> {
  final GetFollowingUseCase getFollowing;
  final UnfollowUserUseCase unfollowUser;

  FollowingBloc({
    required this.getFollowing,
    required this.unfollowUser,
  }) : super(const FollowingState()) {
    on<FollowingLoadRequested>(_onLoadRequested);
    on<FollowingRefreshRequested>(_onRefreshRequested);
    on<FollowingLoadMoreRequested>(_onLoadMoreRequested);
    on<FollowingUnfollowRequested>(_onUnfollowRequested);
  }

  Future<void> _onLoadRequested(
    FollowingLoadRequested event,
    Emitter<FollowingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await getFollowing(GetFollowingParams(
      userId: event.userId,
      page: 0,
      limit: 20,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        ));
      },
      (following) {
        emit(state.copyWith(
          isLoading: false,
          following: following,
          currentPage: 0,
          hasMoreData: following.length >= 20,
        ));
      },
    );
  }

  Future<void> _onRefreshRequested(
    FollowingRefreshRequested event,
    Emitter<FollowingState> emit,
  ) async {
    emit(state.copyWith(following: [], currentPage: 0, hasMoreData: true));
    add(FollowingLoadRequested(userId: event.userId));
  }

  Future<void> _onLoadMoreRequested(
    FollowingLoadMoreRequested event,
    Emitter<FollowingState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await getFollowing(GetFollowingParams(
      userId: event.userId,
      page: nextPage,
      limit: 20,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingMore: false));
      },
      (newFollowing) {
        emit(state.copyWith(
          isLoadingMore: false,
          following: [...state.following, ...newFollowing],
          currentPage: nextPage,
          hasMoreData: newFollowing.length >= 20,
        ));
      },
    );
  }

  Future<void> _onUnfollowRequested(
    FollowingUnfollowRequested event,
    Emitter<FollowingState> emit,
  ) async {
    final result = await unfollowUser(event.targetUserId);

    result.fold(
      (failure) {
        // Handle error
      },
      (followStatus) {
        // Remove user from following list
        final updatedFollowing = state.following
            .where((user) => user.id != event.targetUserId)
            .toList();

        emit(state.copyWith(following: updatedFollowing));
      },
    );
  }
}
