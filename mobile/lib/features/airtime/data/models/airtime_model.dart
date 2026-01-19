import '../../domain/entities/airtime_entity.dart';

class AirtimeOperatorModel extends AirtimeOperator {
  const AirtimeOperatorModel({
    required super.id,
    required super.name,
    required super.code,
    super.logoUrl,
    super.quickAmounts,
    super.minAmount,
    super.maxAmount,
  });

  factory AirtimeOperatorModel.fromJson(Map<String, dynamic> json) {
    return AirtimeOperatorModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      quickAmounts: (json['quickAmounts'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [500, 1000, 2000, 5000, 10000],
      minAmount: (json['minAmount'] as num?)?.toDouble() ?? 100,
      maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 100000,
    );
  }
}

class AirtimeTransactionModel extends AirtimeTransaction {
  const AirtimeTransactionModel({
    required super.id,
    required super.operatorCode,
    required super.phoneNumber,
    required super.amount,
    required super.status,
    required super.createdAt,
    super.reference,
  });

  factory AirtimeTransactionModel.fromJson(Map<String, dynamic> json) {
    return AirtimeTransactionModel(
      id: json['id']?.toString() ?? '',
      operatorCode: json['operatorCode'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'UNKNOWN',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      reference: json['reference'] as String?,
    );
  }
}
