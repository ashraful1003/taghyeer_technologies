import 'package:dio/dio.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../model/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl({required this.dio});

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 30,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw const ServerException('Login failed');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timed out. Please try again.');
      }
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        final message =
            e.response?.data?['message'] ?? 'Invalid credentials';
        throw AuthException(message);
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
