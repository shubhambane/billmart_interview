import 'package:billmart_interview/data/models/pagination_params.dart';
import 'package:billmart_interview/data/repositories/user_repository.dart';
import 'package:billmart_interview/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class UserEvent {}

class FetchUsers extends UserEvent {}

class LoadMoreUsers extends UserEvent {}

class RefreshUsers extends UserEvent {}

// States
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoadingMore extends UserState {
  final UserResponse userResponse;
  final bool hasReachedMax;

  UserLoadingMore(this.userResponse, this.hasReachedMax);
}

class UserLoaded extends UserState {
  final UserResponse userResponse;
  final bool hasReachedMax;
  final PaginationParams paginationParams;

  UserLoaded(this.userResponse, this.hasReachedMax, this.paginationParams);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository(),
        super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<RefreshUsers>(_onRefreshUsers);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final params = PaginationParams();
      final userResponse = await _userRepository.getUsers(params: params);
      final hasReachedMax = userResponse.page >= userResponse.totalPages;
      emit(UserLoaded(userResponse, hasReachedMax, params));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadMoreUsers(
      LoadMoreUsers event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;

      if (currentState.hasReachedMax) return;

      try {
        emit(UserLoadingMore(
            currentState.userResponse, currentState.hasReachedMax));

        final nextParams = currentState.paginationParams
            .copyWith(page: currentState.paginationParams.page + 1);

        final newUserResponse =
            await _userRepository.getUsers(params: nextParams);

        final updatedData = [
          ...currentState.userResponse.data,
          ...newUserResponse.data,
        ];

        final combinedResponse = UserResponse(
          page: newUserResponse.page,
          perPage: newUserResponse.perPage,
          total: newUserResponse.total,
          totalPages: newUserResponse.totalPages,
          data: updatedData,
          support: newUserResponse.support,
        );

        final hasReachedMax = nextParams.page >= newUserResponse.totalPages;

        emit(UserLoaded(combinedResponse, hasReachedMax, nextParams));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshUsers(
      RefreshUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final params = PaginationParams();
      final userResponse = await _userRepository.getUsers(params: params);
      final hasReachedMax = userResponse.page >= userResponse.totalPages;
      emit(UserLoaded(userResponse, hasReachedMax, params));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
