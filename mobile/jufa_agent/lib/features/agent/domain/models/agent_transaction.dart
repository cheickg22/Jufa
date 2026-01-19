class AgentTransaction {
  final String id;
  final String type; // 'deposit' ou 'withdrawal'
  final double amount;
  final double commission;
  final String clientPhone;
  final String clientName;
  final DateTime createdAt;
  final String status; // 'completed', 'pending', 'failed'

  AgentTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.commission,
    required this.clientPhone,
    required this.clientName,
    required this.createdAt,
    required this.status,
  });

  factory AgentTransaction.fromJson(Map<String, dynamic> json) {
    return AgentTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      commission: double.tryParse(json['commission']?.toString() ?? '0') ?? 0.0,
      clientPhone: json['client_phone'] ?? '',
      clientName: json['client_name'] ?? 'Client',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'commission': commission,
      'client_phone': clientPhone,
      'client_name': clientName,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  bool get isDeposit => type == 'deposit';
  bool get isWithdrawal => type == 'withdrawal';
  bool get isCompleted => status == 'completed';
}
