import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../repository/user_repository.dart';

abstract class UserEvent {}

class FetchUsers extends UserEvent {
  final int page;
  FetchUsers({this.page = 1});
}

class RefreshUsers extends UserEvent {
  final int page;
  RefreshUsers({this.page = 1});
}

class NextPage extends UserEvent {}

class PreviousPage extends UserEvent {}

class FetchUserById extends UserEvent {
  final int userId;
  FetchUserById(this.userId);
}

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserResponse userResponse;
  final int currentPage;

  UserLoaded(this.userResponse, {this.currentPage = 1});
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class UserDetailsLoading extends UserState {}

class UserDetailsLoaded extends UserState {
  final UserDetailResponse userDetailResponse;
  UserDetailsLoaded(this.userDetailResponse);
}

class UserDetailsError extends UserState {
  final String message;
  UserDetailsError(this.message);
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  int _currentPage = 1;

  UserBloc(this.repository) : super(UserInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await repository.getUsers(page: event.page);
        _currentPage = event.page;
        emit(UserLoaded(users, currentPage: _currentPage));
      } catch (e) {
        emit(UserError("Failed to load users: ${e.toString()}"));
      }
    });

    on<RefreshUsers>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await repository.getUsers(page: event.page);
        _currentPage = event.page;
        emit(UserLoaded(users, currentPage: _currentPage));
      } catch (e) {
        emit(UserError("Failed to refresh users: ${e.toString()}"));
      }
    });

    on<NextPage>((event, emit) async {
      if (state is UserLoaded) {
        final currentState = state as UserLoaded;
        if (currentState.userResponse.totalPages > _currentPage) {
          emit(UserLoading());
          try {
            final users = await repository.getUsers(page: _currentPage + 1);
            _currentPage += 1;
            emit(UserLoaded(users, currentPage: _currentPage));
          } catch (e) {
            emit(UserError("Failed to load next page: ${e.toString()}"));
          }
        }
      }
    });

    on<PreviousPage>((event, emit) async {
      if (state is UserLoaded && _currentPage > 1) {
        emit(UserLoading());
        try {
          final users = await repository.getUsers(page: _currentPage - 1);
          _currentPage -= 1;
          emit(UserLoaded(users, currentPage: _currentPage));
        } catch (e) {
          emit(UserError("Failed to load previous page: ${e.toString()}"));
        }
      }
    });

    on<FetchUserById>((event, emit) async {
      emit(UserDetailsLoading());
      try {
        final userDetail = await repository.getUserById(event.userId);
        emit(UserDetailsLoaded(userDetail));
      } catch (e) {
        emit(UserDetailsError(e.toString()));
      }
    });
  }
}
