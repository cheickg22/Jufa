import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String id;
  final String walletType;
  final String currency;
  final double balance;
  final double availableBalance;
  final String status;
  final DateTime createdAt;

  const WalletEntity({
    required this.id,
    required this.walletType,
    required this.currency,
    required this.balance,
    required this.availableBalance,
    required this.status,
    required this.createdAt,
  });

  String get formattedBalance {
    final formatted = balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    return '$formatted $currency';
  }

  @override
  List<Object?> get props => [id, walletType, currency, balance, availableBalance, status, createdAt];
}
