import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.walletType,
    required super.currency,
    required super.balance,
    required super.availableBalance,
    required super.status,
    required super.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      walletType: json['walletType'] as String,
      currency: json['currency'] as String? ?? 'XOF',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletType': walletType,
      'currency': currency,
      'balance': balance,
      'availableBalance': availableBalance,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
