import 'package:dartz/dartz.dart';

import '../../../../core/api/network_info.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/repository/post_repository.dart';
import '../datasource/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ({List<PostEntity> posts, int total})>> getPosts({
    required int skip,
    required int limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDatasource.getPosts(skip: skip, limit: limit);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
