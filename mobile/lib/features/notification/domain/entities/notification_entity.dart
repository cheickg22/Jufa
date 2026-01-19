enum NotificationType {
  transactionReceived,
  transactionSent,
  transactionFailed,
  kycApproved,
  kycRejected,
  kycDocumentRequired,
  limitWarning,
  limitReached,
  qrPaymentReceived,
  merchantRelationRequest,
  merchantRelationApproved,
  systemAlert,
  promotional,
}

class NotificationEntity {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? data;
  final bool read;
  final DateTime? readAt;
  final String? referenceId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    this.readAt,
    this.referenceId,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case NotificationType.transactionReceived:
        return 'Paiement reçu';
      case NotificationType.transactionSent:
        return 'Transfert envoyé';
      case NotificationType.transactionFailed:
        return 'Transaction échouée';
      case NotificationType.kycApproved:
        return 'KYC Approuvé';
      case NotificationType.kycRejected:
        return 'KYC Rejeté';
      case NotificationType.kycDocumentRequired:
        return 'Document requis';
      case NotificationType.limitWarning:
        return 'Alerte limite';
      case NotificationType.limitReached:
        return 'Limite atteinte';
      case NotificationType.qrPaymentReceived:
        return 'Paiement QR reçu';
      case NotificationType.merchantRelationRequest:
        return 'Demande partenariat';
      case NotificationType.merchantRelationApproved:
        return 'Partenariat approuvé';
      case NotificationType.systemAlert:
        return 'Alerte système';
      case NotificationType.promotional:
        return 'Promotion';
    }
  }

  bool get isTransaction =>
      type == NotificationType.transactionReceived ||
      type == NotificationType.transactionSent ||
      type == NotificationType.transactionFailed ||
      type == NotificationType.qrPaymentReceived;

  bool get isKyc =>
      type == NotificationType.kycApproved ||
      type == NotificationType.kycRejected ||
      type == NotificationType.kycDocumentRequired;
}
