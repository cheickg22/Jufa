enum AgentTransactionType {
  cashIn,
  cashOut;

  String get displayName {
    switch (this) {
      case AgentTransactionType.cashIn:
        return 'Dépôt Cash';
      case AgentTransactionType.cashOut:
        return 'Retrait Cash';
    }
  }

  static AgentTransactionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CASH_IN':
        return AgentTransactionType.cashIn;
      case 'CASH_OUT':
        return AgentTransactionType.cashOut;
      default:
        return AgentTransactionType.cashIn;
    }
  }
}

enum AgentTransactionStatus {
  pending,
  completed,
  cancelled,
  failed;

  String get displayName {
    switch (this) {
      case AgentTransactionStatus.pending:
        return 'En attente';
      case AgentTransactionStatus.completed:
        return 'Terminée';
      case AgentTransactionStatus.cancelled:
        return 'Annulée';
      case AgentTransactionStatus.failed:
        return 'Échouée';
    }
  }

  static AgentTransactionStatus fromString(String value) {
    return AgentTransactionStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AgentTransactionStatus.pending,
    );
  }
}
