import '../../domain/entities/fee_calculation.dart';

class FeeCalculationModel extends FeeCalculation {
  const FeeCalculationModel({
    required super.amount,
    required super.fee,
    required super.totalAmount,
    required super.agentCommission,
    required super.feeDescription,
  });

  factory FeeCalculationModel.fromJson(Map<String, dynamic> json) {
    return FeeCalculationModel(
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      agentCommission: (json['agentCommission'] as num).toDouble(),
      feeDescription: json['feeDescription'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'fee': fee,
      'totalAmount': totalAmount,
      'agentCommission': agentCommission,
      'feeDescription': feeDescription,
    };
  }
}
