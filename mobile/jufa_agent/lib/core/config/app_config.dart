class AppConfig {
  static const String appName = 'JUFA Agent';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000/api';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Security
  static const bool enableBiometrics = true;
  
  // Storage Keys
  static const String accessTokenKey = 'agent_access_token';
  static const String refreshTokenKey = 'agent_refresh_token';
  static const String agentDataKey = 'agent_data';
  static const String biometricsEnabledKey = 'biometrics_enabled';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Contact
  static const String supportEmail = 'support@jufa.ml';
  static const String supportPhone = '+223 XX XX XX XX';
}
