import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyral/features/profile/presentation/bloc/follower_event.dart';
import 'package:vyral/features/profile/presentation/bloc/follower_state.dart';
import '../../domain/usecases/get_followers_usecase.dart';
import '../../domain/entities/user_entity.dart';

class FollowersBloc extends Bloc<FollowersEvent, FollowersState> {
  final GetFollowersUseCase getFollowers;

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
      (followers) {
        emit(state.copyWith(
          isLoading: false,
          followers: followers,
          currentPage: 0,
          hasMoreData: followers.length >= 20,
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
      limit: 20,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingMore: false));
      },
      (newFollowers) {
        emit(state.copyWith(
          isLoadingMore: false,
          followers: [...state.followers, ...newFollowers],
          currentPage: nextPage,
          hasMoreData: newFollowers.length >= 20,
        ));
      },
    );
  }
}
