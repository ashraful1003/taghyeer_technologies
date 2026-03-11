import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_display.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../bloc/post_bloc.dart';
import '../widget/post_card.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostBloc>().add(PostFetchNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          switch (state.status) {
            case PostStatus.initial:
            case PostStatus.loading:
              return const LoadingDisplay(message: 'Loading posts...');

            case PostStatus.error:
              return ErrorDisplay(
                message: state.errorMessage,
                onRetry: () {
                  context.read<PostBloc>().add(PostFetchRequested());
                },
              );

            case PostStatus.loaded:
            case PostStatus.paginationLoading:
            case PostStatus.paginationError:
              if (state.posts.isEmpty) {
                return const EmptyDisplay(
                  message: 'No posts found.',
                  icon: Icons.article_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostBloc>().add(PostFetchRequested());
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: state.hasReachedMax
                      ? state.posts.length
                      : state.posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.posts.length) {
                      if (state.status == PostStatus.paginationError) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                state.errorMessage,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<PostBloc>()
                                      .add(PostFetchNextPage());
                                },
                                child: const Text('Tap to retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final post = state.posts[index];
                    return PostCard(
                      post: post,
                      onTap: () {
                        context.push('/post/${post.id}', extra: post);
                      },
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
