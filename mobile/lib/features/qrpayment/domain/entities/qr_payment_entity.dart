enum QrCodeType { static_, dynamic }

enum QrPaymentStatus { pending, completed, expired, cancelled }

class MerchantInfo {
  final String id;
  final String phone;
  final String? businessName;

  const MerchantInfo({
    required this.id,
    required this.phone,
    this.businessName,
  });

  String get displayName => businessName ?? phone;
}

class QrCodeEntity {
  final String id;
  final String qrToken;
  final QrCodeType qrType;
  final double? amount;
  final String? description;
  final DateTime? expiresAt;
  final bool active;
  final int scanCount;
  final MerchantInfo merchant;
  final DateTime createdAt;

  const QrCodeEntity({
    required this.id,
    required this.qrToken,
    required this.qrType,
    this.amount,
    this.description,
    this.expiresAt,
    required this.active,
    required this.scanCount,
    required this.merchant,
    required this.createdAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isValid => active && !isExpired;

  String get qrTypeLabel => qrType == QrCodeType.dynamic ? 'Dynamique' : 'Statique';

  String get statusLabel {
    if (!active) return 'Désactivé';
    if (isExpired) return 'Expiré';
    return 'Actif';
  }
}

class PayerInfo {
  final String id;
  final String phone;
  final String? name;

  const PayerInfo({
    required this.id,
    required this.phone,
    this.name,
  });

  String get displayName => name ?? phone;
}

class QrPaymentEntity {
  final String id;
  final String qrCodeId;
  final double amount;
  final QrPaymentStatus status;
  final String? transactionReference;
  final PayerInfo payer;
  final MerchantInfo merchant;
  final DateTime? completedAt;
  final DateTime createdAt;

  const QrPaymentEntity({
    required this.id,
    required this.qrCodeId,
    required this.amount,
    required this.status,
    this.transactionReference,
    required this.payer,
    required this.merchant,
    this.completedAt,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case QrPaymentStatus.pending:
        return 'En cours';
      case QrPaymentStatus.completed:
        return 'Terminé';
      case QrPaymentStatus.expired:
        return 'Expiré';
      case QrPaymentStatus.cancelled:
        return 'Annulé';
    }
  }

  String get formattedAmount => '${amount.toStringAsFixed(0)} XOF';
}
