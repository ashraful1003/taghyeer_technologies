import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entity/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, ({List<ProductEntity> products, int total})>> getProducts({
    required int skip,
    required int limit,
  });
}
