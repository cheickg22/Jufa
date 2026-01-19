abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur de connexion. Vérifiez votre connexion internet.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache local.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  
  const ValidationFailure(super.message, {super.code, this.fieldErrors});
}
