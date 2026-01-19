class AppConfig {
  static const String appName = 'JUFA';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000/api';
  
  static const String skaleetApiUrl = 'https://api.skaleet.com/v1';
  static const String dtOneApiUrl = 'https://api.dtone.com/v1';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Security
  static const bool enableSslPinning = true;
  static const bool enableBiometrics = true;
  static const bool detectRootDevice = true;
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String biometricsEnabledKey = 'biometrics_enabled';
  
  // Hive Boxes
  static const String secureBox = 'secure_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableNegeFeature = true;
  static const bool enableB2BFeatures = false; // MVP: B2C only
  static const bool enableB2GFeatures = false; // MVP: B2C only
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Limits
  static const double maxDailyTransferLimit = 1000000.0; // 1M FCFA
  static const double maxSingleTransferLimit = 500000.0; // 500K FCFA
  
  // Contact
  static const String supportEmail = 'support@jufa.ml';
  static const String supportPhone = '+223 XX XX XX XX';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/jufa';
  static const String twitterUrl = 'https://twitter.com/jufa';
  static const String linkedinUrl = 'https://linkedin.com/company/jufa';
}
