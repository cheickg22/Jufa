import '../../domain/entities/qr_payment_entity.dart';

class MerchantInfoModel extends MerchantInfo {
  const MerchantInfoModel({
    required super.id,
    required super.phone,
    super.businessName,
  });

  factory MerchantInfoModel.fromJson(Map<String, dynamic> json) {
    return MerchantInfoModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      businessName: json['businessName'],
    );
  }
}

class PayerInfoModel extends PayerInfo {
  const PayerInfoModel({
    required super.id,
    required super.phone,
    super.name,
  });

  factory PayerInfoModel.fromJson(Map<String, dynamic> json) {
    return PayerInfoModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'],
    );
  }
}

class QrCodeModel extends QrCodeEntity {
  const QrCodeModel({
    required super.id,
    required super.qrToken,
    required super.qrType,
    super.amount,
    super.description,
    super.expiresAt,
    required super.active,
    required super.scanCount,
    required super.merchant,
    required super.createdAt,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['id'] ?? '',
      qrToken: json['qrToken'] ?? '',
      qrType: _parseQrCodeType(json['qrType']),
      amount: (json['amount'] as num?)?.toDouble(),
      description: json['description'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      active: json['active'] ?? false,
      scanCount: json['scanCount'] ?? 0,
      merchant: MerchantInfoModel.fromJson(json['merchant'] ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  static QrCodeType _parseQrCodeType(String? type) {
    switch (type) {
      case 'DYNAMIC':
        return QrCodeType.dynamic;
      case 'STATIC':
      default:
        return QrCodeType.static_;
    }
  }

  static String qrCodeTypeToString(QrCodeType type) {
    switch (type) {
      case QrCodeType.dynamic:
        return 'DYNAMIC';
      case QrCodeType.static_:
        return 'STATIC';
    }
  }
}

class QrPaymentModel extends QrPaymentEntity {
  const QrPaymentModel({
    required super.id,
    required super.qrCodeId,
    required super.amount,
    required super.status,
    super.transactionReference,
    required super.payer,
    required super.merchant,
    super.completedAt,
    required super.createdAt,
  });

  factory QrPaymentModel.fromJson(Map<String, dynamic> json) {
    return QrPaymentModel(
      id: json['id'] ?? '',
      qrCodeId: json['qrCodeId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(json['status']),
      transactionReference: json['transactionReference'],
      payer: PayerInfoModel.fromJson(json['payer'] ?? {}),
      merchant: MerchantInfoModel.fromJson(json['merchant'] ?? {}),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  static QrPaymentStatus _parseStatus(String? status) {
    switch (status) {
      case 'COMPLETED':
        return QrPaymentStatus.completed;
      case 'EXPIRED':
        return QrPaymentStatus.expired;
      case 'CANCELLED':
        return QrPaymentStatus.cancelled;
      case 'PENDING':
      default:
        return QrPaymentStatus.pending;
    }
  }
}
