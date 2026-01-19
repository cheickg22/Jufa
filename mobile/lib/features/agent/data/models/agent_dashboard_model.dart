import '../../domain/entities/agent_dashboard.dart';

class AgentDashboardModel extends AgentDashboard {
  const AgentDashboardModel({
    required super.walletBalance,
    required super.commissionBalance,
    required super.todayVolume,
    required super.todayTransactions,
    required super.todayCommission,
    super.todayDeposits,
    super.todayWithdrawals,
    required super.weekVolume,
    required super.weekTransactions,
    required super.weekCommission,
    required super.monthVolume,
    required super.monthTransactions,
    required super.monthCommission,
    required super.totalCommissionEarned,
    required super.pendingTransactions,
    super.depositCommissionRate,
    super.withdrawalCommissionRate,
    super.agentCode,
    super.fullName,
    super.hasSecretCode,
  });

  factory AgentDashboardModel.fromJson(Map<String, dynamic> json) {
    return AgentDashboardModel(
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
      commissionBalance: (json['commissionBalance'] as num?)?.toDouble() ?? 0,
      todayVolume: (json['todayVolume'] as num?)?.toDouble() ?? 0,
      todayTransactions: json['todayTransactions'] as int? ?? 0,
      todayCommission: (json['todayCommission'] as num?)?.toDouble() ?? 0,
      todayDeposits: (json['todayDeposits'] as num?)?.toDouble() ?? 0,
      todayWithdrawals: (json['todayWithdrawals'] as num?)?.toDouble() ?? 0,
      weekVolume: (json['weekVolume'] as num?)?.toDouble() ?? 0,
      weekTransactions: json['weekTransactions'] as int? ?? 0,
      weekCommission: (json['weekCommission'] as num?)?.toDouble() ?? 0,
      monthVolume: (json['monthVolume'] as num?)?.toDouble() ?? 0,
      monthTransactions: json['monthTransactions'] as int? ?? 0,
      monthCommission: (json['monthCommission'] as num?)?.toDouble() ?? 0,
      totalCommissionEarned: (json['totalCommissionEarned'] as num?)?.toDouble() ?? 0,
      pendingTransactions: json['pendingTransactions'] as int? ?? 0,
      depositCommissionRate: (json['depositCommissionRate'] as num?)?.toDouble() ?? 1.0,
      withdrawalCommissionRate: (json['withdrawalCommissionRate'] as num?)?.toDouble() ?? 1.5,
      agentCode: json['agentCode'] as String?,
      fullName: json['fullName'] as String?,
      hasSecretCode: json['hasSecretCode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletBalance': walletBalance,
      'commissionBalance': commissionBalance,
      'todayVolume': todayVolume,
      'todayTransactions': todayTransactions,
      'todayCommission': todayCommission,
      'todayDeposits': todayDeposits,
      'todayWithdrawals': todayWithdrawals,
      'weekVolume': weekVolume,
      'weekTransactions': weekTransactions,
      'weekCommission': weekCommission,
      'monthVolume': monthVolume,
      'monthTransactions': monthTransactions,
      'monthCommission': monthCommission,
      'totalCommissionEarned': totalCommissionEarned,
      'pendingTransactions': pendingTransactions,
      'depositCommissionRate': depositCommissionRate,
      'withdrawalCommissionRate': withdrawalCommissionRate,
      'agentCode': agentCode,
      'fullName': fullName,
      'hasSecretCode': hasSecretCode,
    };
  }
}
