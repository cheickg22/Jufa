import '../../domain/entities/kyc_document_entity.dart';

class KycDocumentModel extends KycDocumentEntity {
  const KycDocumentModel({
    required super.id,
    required super.documentType,
    required super.fileUrl,
    super.fileName,
    super.fileSize,
    super.mimeType,
    required super.status,
    super.rejectionReason,
    super.reviewedAt,
    super.reviewedBy,
    super.expiryDate,
    super.documentNumber,
    required super.createdAt,
  });

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'] ?? '',
      documentType: _parseDocumentType(json['documentType']),
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      mimeType: json['mimeType'],
      status: _parseDocumentStatus(json['status']),
      rejectionReason: json['rejectionReason'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy'],
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      documentNumber: json['documentNumber'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static DocumentType _parseDocumentType(String? type) {
    switch (type) {
      case 'NATIONAL_ID':
        return DocumentType.nationalId;
      case 'PASSPORT':
        return DocumentType.passport;
      case 'DRIVER_LICENSE':
        return DocumentType.driverLicense;
      case 'VOTER_CARD':
        return DocumentType.voterCard;
      case 'SELFIE':
        return DocumentType.selfie;
      case 'PROOF_OF_ADDRESS':
        return DocumentType.proofOfAddress;
      case 'RCCM':
        return DocumentType.rccm;
      case 'NIF':
        return DocumentType.nif;
      case 'BANK_STATEMENT':
        return DocumentType.bankStatement;
      default:
        return DocumentType.other;
    }
  }

  static DocumentStatus _parseDocumentStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return DocumentStatus.pending;
      case 'UNDER_REVIEW':
        return DocumentStatus.underReview;
      case 'APPROVED':
        return DocumentStatus.approved;
      case 'REJECTED':
        return DocumentStatus.rejected;
      case 'EXPIRED':
        return DocumentStatus.expired;
      default:
        return DocumentStatus.pending;
    }
  }

  static String documentTypeToString(DocumentType type) {
    switch (type) {
      case DocumentType.nationalId:
        return 'NATIONAL_ID';
      case DocumentType.passport:
        return 'PASSPORT';
      case DocumentType.driverLicense:
        return 'DRIVER_LICENSE';
      case DocumentType.voterCard:
        return 'VOTER_CARD';
      case DocumentType.selfie:
        return 'SELFIE';
      case DocumentType.proofOfAddress:
        return 'PROOF_OF_ADDRESS';
      case DocumentType.rccm:
        return 'RCCM';
      case DocumentType.nif:
        return 'NIF';
      case DocumentType.bankStatement:
        return 'BANK_STATEMENT';
      case DocumentType.other:
        return 'OTHER';
    }
  }
}

class KycStatusModel extends KycStatusEntity {
  const KycStatusModel({
    required super.kycLevel,
    required super.dailyLimit,
    required super.monthlyLimit,
    required super.dailyUsed,
    required super.monthlyUsed,
    required super.requiredDocuments,
    required super.submittedDocuments,
  });

  factory KycStatusModel.fromJson(Map<String, dynamic> json) {
    final submittedDocs = (json['submittedDocuments'] as List<dynamic>?)
            ?.map((e) => KycDocumentModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final requiredDocs = (json['requiredDocuments'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return KycStatusModel(
      kycLevel: json['kycLevel'] ?? 'LEVEL_0',
      dailyLimit: (json['dailyLimit'] ?? 0).toDouble(),
      monthlyLimit: (json['monthlyLimit'] ?? 0).toDouble(),
      dailyUsed: (json['dailyUsed'] ?? 0).toDouble(),
      monthlyUsed: (json['monthlyUsed'] ?? 0).toDouble(),
      requiredDocuments: requiredDocs,
      submittedDocuments: submittedDocs,
    );
  }
}
