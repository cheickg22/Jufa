import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.reference,
    required super.type,
    required super.status,
    required super.amount,
    required super.fee,
    required super.currency,
    super.description,
    super.senderWalletId,
    super.receiverWalletId,
    super.senderPhone,
    super.receiverPhone,
    required super.createdAt,
    super.completedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      reference: json['reference'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'XOF',
      description: json['description'] as String?,
      senderWalletId: json['senderWalletId'] as String?,
      receiverWalletId: json['receiverWalletId'] as String?,
      senderPhone: json['senderPhone'] as String?,
      receiverPhone: json['receiverPhone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'type': type,
      'status': status,
      'amount': amount,
      'fee': fee,
      'currency': currency,
      'description': description,
      'senderWalletId': senderWalletId,
      'receiverWalletId': receiverWalletId,
      'senderPhone': senderPhone,
      'receiverPhone': receiverPhone,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
