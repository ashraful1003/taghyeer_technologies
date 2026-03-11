import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/dio_client.dart';
import '../api/network_info.dart';
import '../theme/theme_bloc.dart';

// Auth
import '../../features/auth/data/datasource/auth_local_datasource.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/auth/domain/usecase/get_cached_user_usecase.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../../features/auth/domain/usecase/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Products
import '../../features/products/data/datasource/product_remote_datasource.dart';
import '../../features/products/data/repository/product_repository_impl.dart';
import '../../features/products/domain/repository/product_repository.dart';
import '../../features/products/domain/usecase/get_products_usecase.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';

// Posts
import '../../features/posts/data/datasource/post_remote_datasource.dart';
import '../../features/posts/data/repository/post_repository_impl.dart';
import '../../features/posts/domain/repository/post_repository.dart';
import '../../features/posts/domain/usecase/get_posts_usecase.dart';
import '../../features/posts/presentation/bloc/post_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ───── External ─────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => DioClient());

  // ───── Core ─────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // ───── Theme ─────
  sl.registerFactory(
    () => ThemeBloc(sharedPreferences: sl()),
  );

  // ───── Auth Feature ─────
  // Datasources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      getCachedUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ───── Products Feature ─────
  sl.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerFactory(
    () => ProductBloc(getProductsUseCase: sl()),
  );

  // ───── Posts Feature ─────
  sl.registerLazySingleton<PostRemoteDatasource>(
    () => PostRemoteDatasourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerFactory(
    () => PostBloc(getPostsUseCase: sl()),
  );
}
