import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user_bloc.dart';

class UserListViewModel {
  void goToNextPage(BuildContext context) {
    context.read<UserBloc>().add(NextPage());
  }

  void goToPreviousPage(BuildContext context) {
    context.read<UserBloc>().add(PreviousPage());
  }

  void refreshUsers(BuildContext context, {int page = 1}) {
    context.read<UserBloc>().add(RefreshUsers(page: page));
  }
}
