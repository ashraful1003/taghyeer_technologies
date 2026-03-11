import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/cache/cache_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../model/user_model.dart';

abstract class AuthLocalDatasource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();
  bool hasUser();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences sharedPreferences;

  AuthLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(CacheKeys.userData, user.toJsonString());
  }

  @override
  Future<UserModel> getCachedUser() async {
    final jsonString = sharedPreferences.getString(CacheKeys.userData);
    if (jsonString != null && jsonString.isNotEmpty) {
      return UserModel.fromJsonString(jsonString);
    }
    throw const CacheException('No cached user found');
  }

  @override
  bool hasUser() {
    return sharedPreferences.containsKey(CacheKeys.userData);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(CacheKeys.userData);
  }
}
