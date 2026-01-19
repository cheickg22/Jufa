import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  });
  
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });
  
  Future<void> verifyOTP({
    required String identifier,
    required String otp,
  });
  
  Future<void> resendOTP({
    required String identifier,
  });
  
  Future<UserModel> getCurrentUser();
  
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  
  AuthRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<void> verifyOTP({
    required String identifier,
    required String otp,
  }) async {
    try {
      await apiClient.post(
        '/auth/verify-otp',
        data: {
          'identifier': identifier,
          'otp': otp,
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<void> resendOTP({
    required String identifier,
  }) async {
    try {
      await apiClient.post(
        '/auth/resend-otp',
        data: {'identifier': identifier},
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
