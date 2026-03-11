import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entity/post_entity.dart';
import '../repository/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, ({List<PostEntity> posts, int total})>> call({
    required int skip,
    required int limit,
  }) {
    return repository.getPosts(skip: skip, limit: limit);
  }
}
