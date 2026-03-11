import 'package:dio/dio.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../model/product_model.dart';

abstract class ProductRemoteDatasource {
  Future<({List<ProductModel> products, int total})> getProducts({
    required int skip,
    required int limit,
  });
}

class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  final Dio dio;

  ProductRemoteDatasourceImpl({required this.dio});

  @override
  Future<({List<ProductModel> products, int total})> getProducts({
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.productsEndpoint,
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final products = (data['products'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
        final total = data['total'] as int;
        return (products: products, total: total);
      } else {
        throw const ServerException('Failed to fetch products');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timed out.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Failed to fetch products');
    }
  }
}
