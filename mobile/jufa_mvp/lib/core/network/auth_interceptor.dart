import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../security/secure_storage_service.dart';
import '../di/injection.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ajouter le token d'accès si disponible
    final accessToken = await _secureStorage.read(AppConfig.accessTokenKey);
    
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    handler.next(options);
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Gérer le refresh token en cas d'erreur 401
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.read(AppConfig.refreshTokenKey);
      
      if (refreshToken != null) {
        try {
          // Tenter de rafraîchir le token
          final newTokens = await _refreshAccessToken(refreshToken);
          
          // Sauvegarder les nouveaux tokens
          await _secureStorage.write(
            AppConfig.accessTokenKey,
            newTokens['access_token'],
          );
          await _secureStorage.write(
            AppConfig.refreshTokenKey,
            newTokens['refresh_token'],
          );
          
          // Réessayer la requête originale
          final opts = Options(
            method: err.requestOptions.method,
            headers: {
              ...err.requestOptions.headers,
              'Authorization': 'Bearer ${newTokens['access_token']}',
            },
          );
          
          final cloneReq = await Dio().request(
            err.requestOptions.path,
            options: opts,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          
          return handler.resolve(cloneReq);
        } catch (e) {
          // Si le refresh échoue, nettoyer les tokens et laisser passer l'erreur
          await _secureStorage.delete(AppConfig.accessTokenKey);
          await _secureStorage.delete(AppConfig.refreshTokenKey);
        }
      }
    }
    
    handler.next(err);
  }
  
  Future<Map<String, dynamic>> _refreshAccessToken(String refreshToken) async {
    final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    
    final response = await dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    
    return response.data;
  }
}
