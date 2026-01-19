import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  
  AuthLocalDataSourceImpl(this.secureStorage);
  
  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await secureStorage.write(AppConfig.userDataKey, userJson);
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }
  
  @override
  Future<UserModel> getCachedUser() async {
    try {
      final userJson = await secureStorage.read(AppConfig.userDataKey);
      
      if (userJson == null) {
        throw CacheException('No cached user found');
      }
      
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }
  
  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(AppConfig.userDataKey);
      await secureStorage.delete(AppConfig.accessTokenKey);
      await secureStorage.delete(AppConfig.refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await secureStorage.read(AppConfig.accessTokenKey);
      return accessToken != null;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await secureStorage.write(AppConfig.accessTokenKey, accessToken);
      await secureStorage.write(AppConfig.refreshTokenKey, refreshToken);
    } catch (e) {
      throw CacheException('Failed to save tokens: $e');
    }
  }
}
