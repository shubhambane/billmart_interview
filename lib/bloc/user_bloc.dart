import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../repository/user_repository.dart';

abstract class UserEvent {}

class FetchUsers extends UserEvent {}

class RefreshUsers extends UserEvent {}

class FetchUserById extends UserEvent {
  final int userId;
  FetchUserById(this.userId);
}

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserResponse userResponse;

  UserLoaded(this.userResponse);
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

  UserBloc(this.repository) : super(UserInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await repository.getUsers();
        emit(UserLoaded(users));
      } catch (e) {
        emit(UserError("Failed to load users: ${e.toString()}"));
      }
    });

    on<RefreshUsers>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await repository.getUsers();
        emit(UserLoaded(users));
      } catch (e) {
        emit(UserError("Failed to refresh users: ${e.toString()}"));
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
