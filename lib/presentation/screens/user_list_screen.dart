import 'package:billmart_interview/presentation/bloc/user_bloc.dart'
    as presentation_bloc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'user_details_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

// Create a wrapper StatelessWidget to provide the UserBloc
class UserListScreenWithBloc extends StatelessWidget {
  const UserListScreenWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<presentation_bloc.UserBloc>(
      create: (context) =>
          presentation_bloc.UserBloc()..add(presentation_bloc.FetchUsers()),
      child: const UserListScreen(),
    );
  }
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.9) {
      final state = context.read<presentation_bloc.UserBloc>().state;
      if (state is presentation_bloc.UserLoaded &&
          !state.hasReachedMax &&
          state is! presentation_bloc.UserLoadingMore) {
        context
            .read<presentation_bloc.UserBloc>()
            .add(presentation_bloc.LoadMoreUsers());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          BlocBuilder<presentation_bloc.UserBloc, presentation_bloc.UserState>(
        builder: (context, state) {
          if (state is presentation_bloc.UserInitial ||
              state is presentation_bloc.UserLoading) {
            return _buildLoadingState();
          } else if (state is presentation_bloc.UserLoaded) {
            return _buildLoadedState(context, state);
          } else if (state is presentation_bloc.UserError) {
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

  Widget _buildLoadedState(
      BuildContext context, presentation_bloc.UserLoaded state) {
    final userResponse = state.userResponse;
    final isLoadingMore = state is presentation_bloc.UserLoadingMore;

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<presentation_bloc.UserBloc>()
            .add(presentation_bloc.RefreshUsers());
      },
      child: CustomScrollView(
        controller: _scrollController,
        shrinkWrap: true,
        slivers: [
          SliverAppBar.medium(
            title: const Text('User List'),
            pinned: true,
            actions: [
              IconButton(
                tooltip: 'Refresh users',
                icon: const Icon(Symbols.refresh),
                onPressed: () {
                  context
                      .read<presentation_bloc.UserBloc>()
                      .add(presentation_bloc.RefreshUsers());
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = userResponse.data[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsScreen(user: user),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: user.id,
                              child: CircleAvatar(
                                radius: 45,
                                backgroundImage: NetworkImage(user.avatar),
                                onBackgroundImageError: (_, __) =>
                                    const Icon(Symbols.error),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: userResponse.data.length,
              ),
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
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
              context
                  .read<presentation_bloc.UserBloc>()
                  .add(presentation_bloc.FetchUsers());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
