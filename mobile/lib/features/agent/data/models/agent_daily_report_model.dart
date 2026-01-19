import '../../domain/entities/agent_daily_report.dart';

class AgentDailyReportModel extends AgentDailyReport {
  const AgentDailyReportModel({
    required super.id,
    required super.reportDate,
    required super.cashInCount,
    required super.cashInAmount,
    required super.cashOutCount,
    required super.cashOutAmount,
    required super.totalTransactions,
    required super.totalVolume,
    required super.totalCommission,
    required super.totalFees,
  });

  factory AgentDailyReportModel.fromJson(Map<String, dynamic> json) {
    return AgentDailyReportModel(
      id: json['id'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      cashInCount: json['cashInCount'] as int? ?? 0,
      cashInAmount: (json['cashInAmount'] as num?)?.toDouble() ?? 0,
      cashOutCount: json['cashOutCount'] as int? ?? 0,
      cashOutAmount: (json['cashOutAmount'] as num?)?.toDouble() ?? 0,
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0,
      totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0,
      totalFees: (json['totalFees'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportDate': reportDate.toIso8601String().split('T')[0],
      'cashInCount': cashInCount,
      'cashInAmount': cashInAmount,
      'cashOutCount': cashOutCount,
      'cashOutAmount': cashOutAmount,
      'totalTransactions': totalTransactions,
      'totalVolume': totalVolume,
      'totalCommission': totalCommission,
      'totalFees': totalFees,
    };
  }
}
