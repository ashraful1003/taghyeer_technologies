import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_constants.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/usecase/get_posts_usecase.dart';

// ───── Events ─────
abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class PostFetchRequested extends PostEvent {}

class PostFetchNextPage extends PostEvent {}

// ───── States ─────
enum PostStatus { initial, loading, loaded, error, paginationLoading, paginationError }

class PostState extends Equatable {
  final PostStatus status;
  final List<PostEntity> posts;
  final String errorMessage;
  final int currentSkip;
  final int total;
  final bool hasReachedMax;

  const PostState({
    this.status = PostStatus.initial,
    this.posts = const [],
    this.errorMessage = '',
    this.currentSkip = 0,
    this.total = 0,
    this.hasReachedMax = false,
  });

  PostState copyWith({
    PostStatus? status,
    List<PostEntity>? posts,
    String? errorMessage,
    int? currentSkip,
    int? total,
    bool? hasReachedMax,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentSkip: currentSkip ?? this.currentSkip,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props =>
      [status, posts, errorMessage, currentSkip, total, hasReachedMax];
}

// ───── Bloc ─────
class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;

  PostBloc({required this.getPostsUseCase}) : super(const PostState()) {
    on<PostFetchRequested>(_onFetchPosts);
    on<PostFetchNextPage>(_onFetchNextPage);
  }

  Future<void> _onFetchPosts(
    PostFetchRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    final result = await getPostsUseCase(
      skip: 0,
      limit: ApiConstants.pageLimit,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: PostStatus.loaded,
        posts: data.posts,
        total: data.total,
        currentSkip: ApiConstants.pageLimit,
        hasReachedMax: data.posts.length >= data.total,
      )),
    );
  }

  Future<void> _onFetchNextPage(
    PostFetchNextPage event,
    Emitter<PostState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == PostStatus.paginationLoading) {
      return;
    }
    emit(state.copyWith(status: PostStatus.paginationLoading));
    final result = await getPostsUseCase(
      skip: state.currentSkip,
      limit: ApiConstants.pageLimit,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.paginationError,
        errorMessage: failure.message,
      )),
      (data) {
        final allPosts = [...state.posts, ...data.posts];
        emit(state.copyWith(
          status: PostStatus.loaded,
          posts: allPosts,
          total: data.total,
          currentSkip: state.currentSkip + ApiConstants.pageLimit,
          hasReachedMax: allPosts.length >= data.total,
        ));
      },
    );
  }
}
