import '../../domain/entities/agent_transaction.dart';
import '../../domain/entities/agent_enums.dart';

class AgentTransactionModel extends AgentTransaction {
  const AgentTransactionModel({
    required super.id,
    required super.reference,
    required super.transactionType,
    required super.transactionTypeName,
    required super.status,
    required super.statusName,
    required super.customerId,
    required super.customerPhone,
    required super.amount,
    required super.fee,
    required super.totalAmount,
    required super.agentCommission,
    super.description,
    required super.createdAt,
    super.completedAt,
  });

  factory AgentTransactionModel.fromJson(Map<String, dynamic> json) {
    return AgentTransactionModel(
      id: json['id'] as String,
      reference: json['reference'] as String,
      transactionType: AgentTransactionType.fromString(json['transactionType'] as String),
      transactionTypeName: json['transactionTypeName'] as String,
      status: AgentTransactionStatus.fromString(json['status'] as String),
      statusName: json['statusName'] as String,
      customerId: json['customerId'] as String,
      customerPhone: json['customerPhone'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      agentCommission: (json['agentCommission'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'transactionType': transactionType.name.toUpperCase(),
      'transactionTypeName': transactionTypeName,
      'status': status.name.toUpperCase(),
      'statusName': statusName,
      'customerId': customerId,
      'customerPhone': customerPhone,
      'amount': amount,
      'fee': fee,
      'totalAmount': totalAmount,
      'agentCommission': agentCommission,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
