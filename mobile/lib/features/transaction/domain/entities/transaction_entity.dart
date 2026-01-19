import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String reference;
  final String type;
  final String status;
  final double amount;
  final double fee;
  final String currency;
  final String? description;
  final String? senderWalletId;
  final String? receiverWalletId;
  final String? senderPhone;
  final String? receiverPhone;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TransactionEntity({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    required this.currency,
    this.description,
    this.senderWalletId,
    this.receiverWalletId,
    this.senderPhone,
    this.receiverPhone,
    required this.createdAt,
    this.completedAt,
  });

  bool get isDebit => senderWalletId != null;
  
  String get formattedAmount {
    final prefix = isDebit ? '-' : '+';
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    return '$prefix$formatted $currency';
  }

  String get displayName {
    if (isDebit && receiverPhone != null) {
      return 'Envoyé à $receiverPhone';
    } else if (!isDebit && senderPhone != null) {
      return 'Reçu de $senderPhone';
    }
    return type;
  }

  @override
  List<Object?> get props => [id, reference, type, status, amount, fee, currency, createdAt];
}
