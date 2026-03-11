import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entity/product_entity.dart';
import '../repository/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, ({List<ProductEntity> products, int total})>> call({
    required int skip,
    required int limit,
  }) {
    return repository.getProducts(skip: skip, limit: limit);
  }
}
