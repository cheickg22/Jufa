class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  ServerException({
    required this.message,
    this.statusCode,
  });
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException([this.message = 'No internet connection']);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  CacheException([this.message = 'Cache error']);
  
  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  
  AuthException({
    required this.message,
    this.statusCode,
  });
  
  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  
  ValidationException({
    required this.message,
    this.errors,
  });
  
  @override
  String toString() => 'ValidationException: $message';
}

class SecurityException implements Exception {
  final String message;
  
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}

class BiometricException implements Exception {
  final String message;
  
  BiometricException([this.message = 'Biometric authentication failed']);
  
  @override
  String toString() => 'BiometricException: $message';
}
