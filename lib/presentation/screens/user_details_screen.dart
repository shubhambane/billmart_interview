import 'package:billmart_interview/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user_bloc.dart';
import '../../repository/user_repository.dart';
import '../viewmodels/user_details_viewmodel.dart';

class UserDetailsScreen extends StatelessWidget {
  final User user;
  final UserDetailsViewModel viewModel = UserDetailsViewModel();

  UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UserBloc(UserRepository())..add(FetchUserById(user.id)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserDetailsLoaded) {
              final userDetail = state.userDetailResponse;
              final updatedUser = userDetail.data;
              final support = userDetail.support;

              return CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Theme.of(context).colorScheme.surface,
                    title: const Text('User Details'),
                    floating: true,
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Hero(
                                tag: updatedUser.id,
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(updatedUser.avatar),
                                  radius: 70,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '${updatedUser.firstName} ${updatedUser.lastName}',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                updatedUser.email,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Support Information',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const Divider(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(support.text),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () async {
                                          try {
                                            await viewModel.launchURL(
                                                context, support.url);
                                          } catch (e) {
                                            viewModel.showErrorSnackbar(
                                                context, e.toString());
                                          }
                                        },
                                        child: Text(
                                          'Visit Support Website',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: 1,
                    ),
                  ),
                ],
              );
            } else if (state is UserDetailsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return _buildInitialUserInfo(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInitialUserInfo(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.avatar),
            radius: 70,
          ),
          const SizedBox(height: 24),
          Text(
            '${user.firstName} ${user.lastName}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('User ID'),
                    trailing: Text('${user.id}'),
                  ),
                  ListTile(
                    title: const Text('Email'),
                    trailing: Text(user.email),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
