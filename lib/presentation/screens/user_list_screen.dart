import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../bloc/user_bloc.dart';
import 'user_details_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserInitial || state is UserLoading) {
            return _buildLoadingState();
          } else if (state is UserLoaded) {
            return _buildLoadedState(context, state);
          } else if (state is UserError) {
            return _buildErrorState(context, state.message);
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading users...'),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, UserLoaded state) {
    final userResponse = state.userResponse;
    final currentPage = state.currentPage;
    final totalPages = state.userResponse.totalPages;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserBloc>().add(RefreshUsers());
      },
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverAppBar.medium(
            title: const Text('User List'),
            pinned: true,
            actions: [
              _buildPaginationControls(context, currentPage, totalPages),
              IconButton(
                tooltip: 'Refresh users',
                icon: const Icon(Symbols.refresh),
                onPressed: () {
                  context.read<UserBloc>().add(RefreshUsers());
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = userResponse.data[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      leading: Hero(
                        tag: user.id,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(user.avatar),
                          onBackgroundImageError: (_, __) =>
                              const Icon(Symbols.error),
                        ),
                      ),
                      title: Text(
                        '${user.firstName} ${user.lastName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsScreen(user: user),
                        ),
                      ),
                    ),
                  );
                },
                childCount: userResponse.data.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(
      BuildContext context, int currentPage, int totalPages) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: currentPage > 1
              ? () => context.read<UserBloc>().add(PreviousPage())
              : null,
        ),
        Text('$currentPage / $totalPages'),
        IconButton(
          icon: const Icon(Symbols.arrow_forward),
          onPressed: currentPage < totalPages
              ? () => context.read<UserBloc>().add(NextPage())
              : null,
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Symbols.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<UserBloc>().add(FetchUsers());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
