class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String loginEndpoint = '/auth/login';
  static const String productsEndpoint = '/products';
  static const String postsEndpoint = '/posts';
  static const int pageLimit = 10;
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
