import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;
  
  const Failure({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

// Échecs réseau
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Pas de connexion Internet. Vérifiez votre réseau.',
  }) : super(message: message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Délai d\'attente dépassé. Réessayez.',
  }) : super(message: message);
}

// Échecs d'authentification
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    String message = 'Erreur d\'authentification.',
    super.code,
  }) : super(message: message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = 'Session expirée. Veuillez vous reconnecter.',
  }) : super(message: message);
}

// Échecs de validation
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
  });
}

// Échecs de cache/stockage
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Erreur de stockage local.',
  }) : super(message: message);
}

// Échecs de sécurité
class SecurityFailure extends Failure {
  const SecurityFailure({
    required super.message,
  });
}

// Échecs métier
class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    super.code,
  });
}

class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure({
    String message = 'Solde insuffisant pour effectuer cette opération.',
  }) : super(message: message);
}

class TransactionLimitExceededFailure extends Failure {
  const TransactionLimitExceededFailure({
    String message = 'Limite de transaction dépassée.',
  }) : super(message: message);
}

class KYCRequiredFailure extends Failure {
  const KYCRequiredFailure({
    String message = 'Vérification d\'identité requise pour cette opération.',
  }) : super(message: message);
}

// Échecs génériques
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Une erreur inattendue s\'est produite.',
  }) : super(message: message);
}
