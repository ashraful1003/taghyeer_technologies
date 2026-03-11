import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_display.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../bloc/product_bloc.dart';
import '../widget/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
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
      context.read<ProductBloc>().add(ProductFetchNextPage());
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
        title: const Text('Products'),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductStatus.initial:
            case ProductStatus.loading:
              return const LoadingDisplay(message: 'Loading products...');

            case ProductStatus.error:
              return ErrorDisplay(
                message: state.errorMessage,
                onRetry: () {
                  context.read<ProductBloc>().add(ProductFetchRequested());
                },
              );

            case ProductStatus.loaded:
            case ProductStatus.paginationLoading:
            case ProductStatus.paginationError:
              if (state.products.isEmpty) {
                return const EmptyDisplay(
                  message: 'No products found.',
                  icon: Icons.shopping_bag_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProductBloc>().add(ProductFetchRequested());
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: state.hasReachedMax
                      ? state.products.length
                      : state.products.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.products.length) {
                      // Pagination loader / error
                      if (state.status == ProductStatus.paginationError) {
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
                                      .read<ProductBloc>()
                                      .add(ProductFetchNextPage());
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
                    final product = state.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        context.push('/product/${product.id}', extra: product);
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
