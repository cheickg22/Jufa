class AgentStats {
  final String agentId;
  final double balance;
  final int todayDeposits;
  final int todayWithdrawals;
  final double todayCommissions;
  final double totalCommissions;
  final int totalTransactions;

  AgentStats({
    required this.agentId,
    required this.balance,
    required this.todayDeposits,
    required this.todayWithdrawals,
    required this.todayCommissions,
    required this.totalCommissions,
    required this.totalTransactions,
  });

  factory AgentStats.fromJson(Map<String, dynamic> json) {
    return AgentStats(
      agentId: json['agent_id']?.toString() ?? '',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      todayDeposits: json['today_deposits'] ?? 0,
      todayWithdrawals: json['today_withdrawals'] ?? 0,
      todayCommissions: double.tryParse(json['today_commissions']?.toString() ?? '0') ?? 0.0,
      totalCommissions: double.tryParse(json['total_commissions']?.toString() ?? '0') ?? 0.0,
      totalTransactions: json['total_transactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent_id': agentId,
      'balance': balance,
      'today_deposits': todayDeposits,
      'today_withdrawals': todayWithdrawals,
      'today_commissions': todayCommissions,
      'total_commissions': totalCommissions,
      'total_transactions': totalTransactions,
    };
  }
}
