import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screen/login_screen.dart';
import '../../features/home/presentation/screen/home_screen.dart';
import '../../features/products/domain/entity/product_entity.dart';
import '../../features/products/presentation/screen/product_detail_screen.dart';
import '../../features/posts/domain/entity/post_entity.dart';
import '../../features/posts/presentation/screen/post_detail_screen.dart';
import '../di/injection_container.dart';
import '../../features/auth/data/datasource/auth_local_datasource.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final localDatasource = sl<AuthLocalDatasource>();
      final isLoggedIn = localDatasource.hasUser();
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        pageBuilder: (context, state) {
          final product = state.extra as ProductEntity;
          return MaterialPage(
            key: state.pageKey,
            child: ProductDetailScreen(product: product),
          );
        },
      ),
      GoRoute(
        path: '/post/:id',
        pageBuilder: (context, state) {
          final post = state.extra as PostEntity;
          return MaterialPage(
            key: state.pageKey,
            child: PostDetailScreen(post: post),
          );
        },
      ),
    ],
  );
}
