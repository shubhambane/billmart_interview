import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserBloc>().add(RefreshUsers());
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        slivers: [
          _buildAppBar(context),
          _buildUserList(context, state),
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar.medium(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      title: const Text('User List'),
      floating: true,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh users',
          onPressed: () {
            context.read<UserBloc>().add(RefreshUsers());
          },
        ),
      ],
    );
  }

  Widget _buildUserList(BuildContext context, UserLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildUserListItem(
            context,
            state.userResponse.data[index],
          ),
          childCount: state.userResponse.data.length,
        ),
      ),
    );
  }

  Widget _buildUserListItem(BuildContext context, dynamic user) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: user.id,
          child: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(user.avatar),
            onBackgroundImageError: (_, __) => const Icon(Icons.error),
          ),
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          user.email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToUserDetails(context, user),
      ),
    );
  }

  void _navigateToUserDetails(BuildContext context, dynamic user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(user: user),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
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
