import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entity/post_entity.dart';

abstract class PostRepository {
  Future<Either<Failure, ({List<PostEntity> posts, int total})>> getPosts({
    required int skip,
    required int limit,
  });
}
