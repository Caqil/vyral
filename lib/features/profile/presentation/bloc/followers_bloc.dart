// lib/features/profile/presentation/bloc/followers_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/features/profile/presentation/bloc/follower_event.dart';
import 'package:vyral/features/profile/presentation/bloc/follower_state.dart';
import '../../domain/usecases/get_followers_usecase.dart';
import '../../domain/entities/user_entity.dart';

class FollowersBloc extends Bloc<FollowersEvent, FollowersState> {
  final GetFollowersUseCase getFollowers;
  static const int _pageSize = 20; // Define page size as constant

  FollowersBloc({
    required this.getFollowers,
  }) : super(const FollowersState()) {
    on<FollowersLoadRequested>(_onLoadRequested);
    on<FollowersRefreshRequested>(_onRefreshRequested);
    on<FollowersLoadMoreRequested>(_onLoadMoreRequested);
  }

  Future<void> _onLoadRequested(
    FollowersLoadRequested event,
    Emitter<FollowersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await getFollowers(GetFollowersParams(
      userId: event.userId,
      page: 0,
      limit: _pageSize,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: failure.message,
        ));
      },
      (followers) {
        emit(state.copyWith(
          isLoading: false,
          followers: followers,
          currentPage: 0,
          hasMoreData: followers.length == _pageSize,
        ));
      },
    );
  }

  Future<void> _onRefreshRequested(
    FollowersRefreshRequested event,
    Emitter<FollowersState> emit,
  ) async {
    emit(state.copyWith(followers: [], currentPage: 0, hasMoreData: true));
    add(FollowersLoadRequested(userId: event.userId));
  }

  Future<void> _onLoadMoreRequested(
    FollowersLoadMoreRequested event,
    Emitter<FollowersState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await getFollowers(GetFollowersParams(
      userId: event.userId,
      page: nextPage,
      limit: _pageSize,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingMore: false));
      },
      (newFollowers) {
        final existingIds = state.followers.map((f) => f.id).toSet();
        final uniqueNewFollowers = newFollowers
            .where((follower) => !existingIds.contains(follower.id))
            .toList();

        emit(state.copyWith(
          isLoadingMore: false,
          followers: [...state.followers, ...uniqueNewFollowers],
          currentPage: nextPage,
          hasMoreData: newFollowers.length == _pageSize,
        ));
      },
    );
  }
}
