class FeeCalculation {
  final double amount;
  final double fee;
  final double totalAmount;
  final double agentCommission;
  final String feeDescription;

  const FeeCalculation({
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.agentCommission,
    required this.feeDescription,
  });
}
