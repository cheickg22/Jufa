import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../constants/storage_keys.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _storage;
  
  ApiClient(this._storage) : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));
  }
  
  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(StorageKeys.accessToken);
    debugPrint('[ApiClient] Request: ${options.method} ${options.uri}');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('[ApiClient] Token present: ${token.substring(0, 20)}...');
    } else {
      debugPrint('[ApiClient] No token available');
    }
    handler.next(options);
  }
  
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[ApiClient] Response: ${response.statusCode} for ${response.requestOptions.uri}');
    handler.next(response);
  }
  
  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    debugPrint('[ApiClient] Error: ${error.type} - ${error.message}');
    debugPrint('[ApiClient] Status: ${error.response?.statusCode}');
    if (error.response?.statusCode == 401) {
      debugPrint('[ApiClient] 401 received, attempting token refresh...');
      final refreshed = await _refreshToken();
      if (refreshed) {
        debugPrint('[ApiClient] Token refresh successful, retrying request');
        final token = await _storage.read(StorageKeys.accessToken);
        error.requestOptions.headers['Authorization'] = 'Bearer $token';
        
        final response = await _dio.fetch(error.requestOptions);
        handler.resolve(response);
        return;
      }
      debugPrint('[ApiClient] Token refresh failed');
    }
    handler.next(error);
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(StorageKeys.refreshToken);
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        ApiConstants.authRefreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': ''}),
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final newToken = response.data['data']['accessToken'];
        await _storage.write(StorageKeys.accessToken, newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadMultipart(
    String path, {
    required String filePath,
    required String fileName,
    required String fieldName,
    Map<String, dynamic>? fields,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath, filename: fileName),
        ...?fields,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.data['success'] == true) {
      return response.data;
    }
    throw ServerException(
      response.data['error']?['message'] ?? 'Unknown error',
      code: response.data['error']?['code'],
      statusCode: response.statusCode,
    );
  }
  
  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    
    if (e.response?.statusCode == 401) {
      return const UnauthorizedException();
    }
    
    final data = e.response?.data;
    if (data != null && data is Map) {
      return ServerException(
        data['error']?['message'] ?? 'Server error',
        code: data['error']?['code'],
        statusCode: e.response?.statusCode,
      );
    }
    
    return ServerException('An error occurred', statusCode: e.response?.statusCode);
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});
