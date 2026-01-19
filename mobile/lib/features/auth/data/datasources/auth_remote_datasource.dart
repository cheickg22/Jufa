import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register(String phone, String password, String userType);
  Future<AuthResponseModel> verifyOtp(String userId, String otp);
  Future<AuthResponseModel> login(String phone, String password);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  
  AuthRemoteDataSourceImpl(this._apiClient);
  
  @override
  Future<RegisterResponseModel> register(String phone, String password, String userType) async {
    final response = await _apiClient.post(
      ApiConstants.authRegister,
      data: {
        'phone': phone,
        'password': password,
        'userType': userType,
      },
    );
    return RegisterResponseModel.fromJson(response['data']);
  }
  
  @override
  Future<AuthResponseModel> verifyOtp(String userId, String otp) async {
    final response = await _apiClient.post(
      ApiConstants.authVerifyOtp,
      data: {
        'userId': userId,
        'otp': otp,
      },
    );
    return AuthResponseModel.fromJson(response['data']);
  }
  
  @override
  Future<AuthResponseModel> login(String phone, String password) async {
    final response = await _apiClient.post(
      ApiConstants.authLogin,
      data: {
        'phone': phone,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(response['data']);
  }
  
  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      ApiConstants.authRefreshToken,
      data: {'refreshToken': refreshToken},
    );
    return AuthResponseModel.fromJson(response['data']);
  }
  
  @override
  Future<void> logout() async {
    await _apiClient.post(ApiConstants.authLogout);
  }
}
