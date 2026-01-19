enum MobileMoneyProvider {
  orangeMoney,
  moovMoney;

  String get displayName {
    switch (this) {
      case orangeMoney:
        return 'Orange Money';
      case moovMoney:
        return 'Moov Money';
    }
  }

  String get code {
    switch (this) {
      case orangeMoney:
        return 'orange';
      case moovMoney:
        return 'moov';
    }
  }

  String get iconAsset {
    switch (this) {
      case orangeMoney:
        return 'assets/icons/orange_money.png';
      case moovMoney:
        return 'assets/icons/moov_money.png';
    }
  }

  static MobileMoneyProvider fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ORANGE_MONEY':
        return orangeMoney;
      case 'MOOV_MONEY':
        return moovMoney;
      default:
        return orangeMoney;
    }
  }
}

enum MobileMoneyOperationType {
  deposit,
  withdrawal;

  String get displayName {
    switch (this) {
      case deposit:
        return 'Dépôt';
      case withdrawal:
        return 'Retrait';
    }
  }

  static MobileMoneyOperationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DEPOSIT':
        return deposit;
      case 'WITHDRAWAL':
        return withdrawal;
      default:
        return deposit;
    }
  }
}

enum MobileMoneyOperationStatus {
  pending,
  processing,
  awaitingConfirmation,
  completed,
  failed,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case pending:
        return 'En attente';
      case processing:
        return 'En cours';
      case awaitingConfirmation:
        return 'Confirmation requise';
      case completed:
        return 'Terminé';
      case failed:
        return 'Échoué';
      case cancelled:
        return 'Annulé';
      case expired:
        return 'Expiré';
    }
  }

  bool get isTerminal =>
      this == completed || this == failed || this == cancelled || this == expired;

  static MobileMoneyOperationStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return pending;
      case 'PROCESSING':
        return processing;
      case 'AWAITING_CONFIRMATION':
        return awaitingConfirmation;
      case 'COMPLETED':
        return completed;
      case 'FAILED':
        return failed;
      case 'CANCELLED':
        return cancelled;
      case 'EXPIRED':
        return expired;
      default:
        return pending;
    }
  }
}

class MobileMoneyOperationEntity {
  final String id;
  final String reference;
  final MobileMoneyOperationType operationType;
  final MobileMoneyProvider provider;
  final MobileMoneyOperationStatus status;
  final String phoneNumber;
  final double amount;
  final double fee;
  final double totalAmount;
  final String currency;
  final String? description;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;

  MobileMoneyOperationEntity({
    required this.id,
    required this.reference,
    required this.operationType,
    required this.provider,
    required this.status,
    required this.phoneNumber,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.currency,
    this.description,
    this.failureReason,
    required this.createdAt,
    this.completedAt,
    this.expiresAt,
  });

  bool get isDeposit => operationType == MobileMoneyOperationType.deposit;
  bool get isWithdrawal => operationType == MobileMoneyOperationType.withdrawal;
  bool get needsConfirmation => status == MobileMoneyOperationStatus.awaitingConfirmation;
  bool get isCompleted => status == MobileMoneyOperationStatus.completed;
  bool get isFailed => status == MobileMoneyOperationStatus.failed;
}

class ProviderInfoEntity {
  final MobileMoneyProvider provider;
  final String name;
  final bool depositEnabled;
  final bool withdrawalEnabled;
  final double minDeposit;
  final double maxDeposit;
  final double minWithdrawal;
  final double maxWithdrawal;
  final double depositFeePercent;
  final double withdrawalFeePercent;

  ProviderInfoEntity({
    required this.provider,
    required this.name,
    required this.depositEnabled,
    required this.withdrawalEnabled,
    required this.minDeposit,
    required this.maxDeposit,
    required this.minWithdrawal,
    required this.maxWithdrawal,
    required this.depositFeePercent,
    required this.withdrawalFeePercent,
  });
}
