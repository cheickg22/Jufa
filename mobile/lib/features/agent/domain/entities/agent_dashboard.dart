class AgentDashboard {
  final double walletBalance;
  final double commissionBalance;
  final double todayVolume;
  final int todayTransactions;
  final double todayCommission;
  final double todayDeposits;
  final double todayWithdrawals;
  final double weekVolume;
  final int weekTransactions;
  final double weekCommission;
  final double monthVolume;
  final int monthTransactions;
  final double monthCommission;
  final double totalCommissionEarned;
  final int pendingTransactions;
  final double depositCommissionRate;
  final double withdrawalCommissionRate;
  final String? agentCode;
  final String? fullName;
  final bool hasSecretCode;

  const AgentDashboard({
    required this.walletBalance,
    required this.commissionBalance,
    required this.todayVolume,
    required this.todayTransactions,
    required this.todayCommission,
    this.todayDeposits = 0,
    this.todayWithdrawals = 0,
    required this.weekVolume,
    required this.weekTransactions,
    required this.weekCommission,
    required this.monthVolume,
    required this.monthTransactions,
    required this.monthCommission,
    required this.totalCommissionEarned,
    required this.pendingTransactions,
    this.depositCommissionRate = 1.0,
    this.withdrawalCommissionRate = 1.5,
    this.agentCode,
    this.fullName,
    this.hasSecretCode = false,
  });
}
