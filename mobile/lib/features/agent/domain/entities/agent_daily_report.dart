import 'dart:core';

class AgentDailyReport {
  final String id;
  final DateTime reportDate;
  final int cashInCount;
  final double cashInAmount;
  final int cashOutCount;
  final double cashOutAmount;
  final int totalTransactions;
  final double totalVolume;
  final double totalCommission;
  final double totalFees;

  const AgentDailyReport({
    required this.id,
    required this.reportDate,
    required this.cashInCount,
    required this.cashInAmount,
    required this.cashOutCount,
    required this.cashOutAmount,
    required this.totalTransactions,
    required this.totalVolume,
    required this.totalCommission,
    required this.totalFees,
  });
}
