import '../../domain/entities/mobile_money_entity.dart';

class MobileMoneyOperationModel extends MobileMoneyOperationEntity {
  MobileMoneyOperationModel({
    required super.id,
    required super.reference,
    required super.operationType,
    required super.provider,
    required super.status,
    required super.phoneNumber,
    required super.amount,
    required super.fee,
    required super.totalAmount,
    required super.currency,
    super.description,
    super.failureReason,
    required super.createdAt,
    super.completedAt,
    super.expiresAt,
  });

  factory MobileMoneyOperationModel.fromJson(Map<String, dynamic> json) {
    return MobileMoneyOperationModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      operationType: MobileMoneyOperationType.fromString(json['operationType'] ?? 'DEPOSIT'),
      provider: MobileMoneyProvider.fromString(json['provider'] ?? 'ORANGE_MONEY'),
      status: MobileMoneyOperationStatus.fromString(json['status'] ?? 'PENDING'),
      phoneNumber: json['phoneNumber'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      description: json['description'],
      failureReason: json['failureReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }
}

class ProviderInfoModel extends ProviderInfoEntity {
  ProviderInfoModel({
    required super.provider,
    required super.name,
    required super.depositEnabled,
    required super.withdrawalEnabled,
    required super.minDeposit,
    required super.maxDeposit,
    required super.minWithdrawal,
    required super.maxWithdrawal,
    required super.depositFeePercent,
    required super.withdrawalFeePercent,
  });

  factory ProviderInfoModel.fromJson(Map<String, dynamic> json) {
    return ProviderInfoModel(
      provider: MobileMoneyProvider.fromString(json['provider'] ?? 'ORANGE_MONEY'),
      name: json['name'] ?? '',
      depositEnabled: json['depositEnabled'] ?? true,
      withdrawalEnabled: json['withdrawalEnabled'] ?? true,
      minDeposit: (json['minDeposit'] ?? 0).toDouble(),
      maxDeposit: (json['maxDeposit'] ?? 0).toDouble(),
      minWithdrawal: (json['minWithdrawal'] ?? 0).toDouble(),
      maxWithdrawal: (json['maxWithdrawal'] ?? 0).toDouble(),
      depositFeePercent: (json['depositFeePercent'] ?? 0).toDouble(),
      withdrawalFeePercent: (json['withdrawalFeePercent'] ?? 0).toDouble(),
    );
  }
}

class DepositRequestModel {
  final String provider;
  final String phoneNumber;
  final double amount;

  DepositRequestModel({
    required this.provider,
    required this.phoneNumber,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'phoneNumber': phoneNumber,
        'amount': amount,
      };
}

class WithdrawalRequestModel {
  final String provider;
  final String phoneNumber;
  final double amount;

  WithdrawalRequestModel({
    required this.provider,
    required this.phoneNumber,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'phoneNumber': phoneNumber,
        'amount': amount,
      };
}

class ConfirmDepositRequestModel {
  final String reference;
  final String? otp;

  ConfirmDepositRequestModel({
    required this.reference,
    this.otp,
  });

  Map<String, dynamic> toJson() => {
        'reference': reference,
        if (otp != null) 'otp': otp,
      };
}
