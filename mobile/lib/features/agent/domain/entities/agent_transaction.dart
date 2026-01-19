import 'agent_enums.dart';

class AgentTransaction {
  final String id;
  final String reference;
  final AgentTransactionType transactionType;
  final String transactionTypeName;
  final AgentTransactionStatus status;
  final String statusName;
  final String customerId;
  final String customerPhone;
  final double amount;
  final double fee;
  final double totalAmount;
  final double agentCommission;
  final String? description;
  final DateTime createdAt;
  final DateTime? completedAt;

  const AgentTransaction({
    required this.id,
    required this.reference,
    required this.transactionType,
    required this.transactionTypeName,
    required this.status,
    required this.statusName,
    required this.customerId,
    required this.customerPhone,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.agentCommission,
    this.description,
    required this.createdAt,
    this.completedAt,
  });
}
