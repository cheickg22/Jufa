import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../error/exceptions.dart';
import 'auth_interceptor.dart';
import 'network_info.dart';

class ApiClient {
  late final Dio _dio;
  final NetworkInfo networkInfo;
  
  ApiClient({
    required this.networkInfo,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    ]);
  }
  
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<void> _checkConnectivity() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('Pas de connexion Internet');
    }
  }
  
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Délai de connexion dépassé');
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 
                       error.response?.statusMessage ?? 
                       'Erreur serveur';
        
        if (statusCode == 401) {
          return AuthException(
            message: 'Session expirée',
            statusCode: statusCode,
          );
        }
        
        if (statusCode == 422) {
          return ValidationException(
            message: message,
            errors: error.response?.data['errors'],
          );
        }
        
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
        
      case DioExceptionType.cancel:
        return ServerException(message: 'Requête annulée');
        
      case DioExceptionType.connectionError:
        return NetworkException('Erreur de connexion au serveur');
        
      default:
        return ServerException(
          message: error.message ?? 'Erreur inconnue',
        );
    }
  }
}
