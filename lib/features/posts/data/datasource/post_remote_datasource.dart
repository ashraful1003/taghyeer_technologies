import 'package:dio/dio.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../model/post_model.dart';

abstract class PostRemoteDatasource {
  Future<({List<PostModel> posts, int total})> getPosts({
    required int skip,
    required int limit,
  });
}

class PostRemoteDatasourceImpl implements PostRemoteDatasource {
  final Dio dio;

  PostRemoteDatasourceImpl({required this.dio});

  @override
  Future<({List<PostModel> posts, int total})> getPosts({
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.postsEndpoint,
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final posts = (data['posts'] as List)
            .map((json) => PostModel.fromJson(json))
            .toList();
        final total = data['total'] as int;
        return (posts: posts, total: total);
      } else {
        throw const ServerException('Failed to fetch posts');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timed out.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Failed to fetch posts');
    }
  }
}
