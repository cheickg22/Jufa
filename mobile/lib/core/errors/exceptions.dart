class ServerException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  
  const ServerException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  
  const CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  
  const UnauthorizedException([this.message = 'Unauthorized']);

  @override
  String toString() => message;
}
