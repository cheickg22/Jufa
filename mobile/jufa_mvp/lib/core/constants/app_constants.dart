class AppConstants {
  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp phoneRegex = RegExp(
    r'^\+?[0-9]{8,15}$',
  );
  
  static final RegExp malianPhoneRegex = RegExp(
    r'^(\+223)?[0-9]{8}$',
  );
  
  // Currency
  static const String currency = 'FCFA';
  static const String currencySymbol = 'FCFA';
  
  // Languages
  static const String defaultLanguage = 'fr';
  static const List<String> supportedLanguages = ['fr', 'bm', 'en'];
  
  // Transaction Types
  static const String transferType = 'transfer';
  static const String paymentType = 'payment';
  static const String airtimeType = 'airtime';
  static const String negeType = 'nege';
  static const String cashInType = 'cash_in';
  static const String cashOutType = 'cash_out';
  
  // Transaction Status
  static const String pendingStatus = 'pending';
  static const String successStatus = 'success';
  static const String failedStatus = 'failed';
  static const String cancelledStatus = 'cancelled';
  
  // KYC Levels
  static const int kycLevel0 = 0; // Non vérifié
  static const int kycLevel1 = 1; // Vérifié basique
  static const int kycLevel2 = 2; // Vérifié complet
  static const int kycLevel3 = 3; // Vérifié premium
  
  // Document Types
  static const String idCardType = 'id_card';
  static const String passportType = 'passport';
  static const String drivingLicenseType = 'driving_license';
  static const String selfieType = 'selfie';
  
  // Mobile Operators (Mali)
  static const List<String> mobileOperators = [
    'Orange Mali',
    'Malitel',
    'Moov Africa',
  ];
  
  // Bill Types
  static const List<String> billTypes = [
    'EDM', // Électricité
    'SOMAGEP', // Eau
    'Orange Internet',
    'Malitel Internet',
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Snackbar Duration
  static const Duration snackbarDuration = Duration(seconds: 3);
  
  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
  
  // Session Timeout
  static const Duration sessionTimeout = Duration(minutes: 15);
}
