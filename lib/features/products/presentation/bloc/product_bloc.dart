import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_constants.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/usecase/get_products_usecase.dart';

// ───── Events ─────
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductFetchRequested extends ProductEvent {}

class ProductFetchNextPage extends ProductEvent {}

// ───── States ─────
enum ProductStatus { initial, loading, loaded, error, paginationLoading, paginationError }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> products;
  final String errorMessage;
  final int currentSkip;
  final int total;
  final bool hasReachedMax;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.errorMessage = '',
    this.currentSkip = 0,
    this.total = 0,
    this.hasReachedMax = false,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    String? errorMessage,
    int? currentSkip,
    int? total,
    bool? hasReachedMax,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
      currentSkip: currentSkip ?? this.currentSkip,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props =>
      [status, products, errorMessage, currentSkip, total, hasReachedMax];
}

// ───── Bloc ─────
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;

  ProductBloc({required this.getProductsUseCase}) : super(const ProductState()) {
    on<ProductFetchRequested>(_onFetchProducts);
    on<ProductFetchNextPage>(_onFetchNextPage);
  }

  Future<void> _onFetchProducts(
    ProductFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await getProductsUseCase(
      skip: 0,
      limit: ApiConstants.pageLimit,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: ProductStatus.loaded,
        products: data.products,
        total: data.total,
        currentSkip: ApiConstants.pageLimit,
        hasReachedMax: data.products.length >= data.total,
      )),
    );
  }

  Future<void> _onFetchNextPage(
    ProductFetchNextPage event,
    Emitter<ProductState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == ProductStatus.paginationLoading) {
      return;
    }
    emit(state.copyWith(status: ProductStatus.paginationLoading));
    final result = await getProductsUseCase(
      skip: state.currentSkip,
      limit: ApiConstants.pageLimit,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProductStatus.paginationError,
        errorMessage: failure.message,
      )),
      (data) {
        final allProducts = [...state.products, ...data.products];
        emit(state.copyWith(
          status: ProductStatus.loaded,
          products: allProducts,
          total: data.total,
          currentSkip: state.currentSkip + ApiConstants.pageLimit,
          hasReachedMax: allProducts.length >= data.total,
        ));
      },
    );
  }
}
