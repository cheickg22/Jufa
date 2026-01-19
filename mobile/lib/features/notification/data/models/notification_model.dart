import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? data;
  final bool read;
  final String? readAt;
  final String? referenceId;
  final String createdAt;

  NotificationModel({
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      data: json['data'],
      read: json['read'] ?? false,
      readAt: json['readAt'],
      referenceId: json['referenceId'],
      createdAt: json['createdAt'],
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: _parseType(type),
      title: title,
      body: body,
      data: data,
      read: read,
      readAt: readAt != null ? DateTime.parse(readAt!) : null,
      referenceId: referenceId,
      createdAt: DateTime.parse(createdAt),
    );
  }

  NotificationType _parseType(String type) {
    switch (type) {
      case 'TRANSACTION_RECEIVED':
        return NotificationType.transactionReceived;
      case 'TRANSACTION_SENT':
        return NotificationType.transactionSent;
      case 'TRANSACTION_FAILED':
        return NotificationType.transactionFailed;
      case 'KYC_APPROVED':
        return NotificationType.kycApproved;
      case 'KYC_REJECTED':
        return NotificationType.kycRejected;
      case 'KYC_DOCUMENT_REQUIRED':
        return NotificationType.kycDocumentRequired;
      case 'LIMIT_WARNING':
        return NotificationType.limitWarning;
      case 'LIMIT_REACHED':
        return NotificationType.limitReached;
      case 'QR_PAYMENT_RECEIVED':
        return NotificationType.qrPaymentReceived;
      case 'MERCHANT_RELATION_REQUEST':
        return NotificationType.merchantRelationRequest;
      case 'MERCHANT_RELATION_APPROVED':
        return NotificationType.merchantRelationApproved;
      case 'SYSTEM_ALERT':
        return NotificationType.systemAlert;
      case 'PROMOTIONAL':
        return NotificationType.promotional;
      default:
        return NotificationType.systemAlert;
    }
  }
}
