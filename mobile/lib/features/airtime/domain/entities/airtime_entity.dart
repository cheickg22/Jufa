class AirtimeOperator {
  final String id;
  final String name;
  final String code;
  final String? logoUrl;
  final List<int> quickAmounts;
  final double minAmount;
  final double maxAmount;

  const AirtimeOperator({
    required this.id,
    required this.name,
    required this.code,
    this.logoUrl,
    this.quickAmounts = const [500, 1000, 2000, 5000, 10000],
    this.minAmount = 100,
    this.maxAmount = 100000,
  });
}

class AirtimeTransaction {
  final String id;
  final String operatorCode;
  final String phoneNumber;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? reference;

  const AirtimeTransaction({
    required this.id,
    required this.operatorCode,
    required this.phoneNumber,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.reference,
  });
}
