enum DocumentType {
  nationalId,
  passport,
  driverLicense,
  voterCard,
  selfie,
  proofOfAddress,
  rccm,
  nif,
  bankStatement,
  other,
}

enum DocumentStatus {
  pending,
  underReview,
  approved,
  rejected,
  expired,
}

class KycDocumentEntity {
  final String id;
  final DocumentType documentType;
  final String fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final DocumentStatus status;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final DateTime? expiryDate;
  final String? documentNumber;
  final DateTime createdAt;

  const KycDocumentEntity({
    required this.id,
    required this.documentType,
    required this.fileUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    required this.status,
    this.rejectionReason,
    this.reviewedAt,
    this.reviewedBy,
    this.expiryDate,
    this.documentNumber,
    required this.createdAt,
  });

  String get documentTypeLabel {
    switch (documentType) {
      case DocumentType.nationalId:
        return "Carte d'identité";
      case DocumentType.passport:
        return 'Passeport';
      case DocumentType.driverLicense:
        return 'Permis de conduire';
      case DocumentType.voterCard:
        return 'Carte d\'électeur';
      case DocumentType.selfie:
        return 'Photo selfie';
      case DocumentType.proofOfAddress:
        return 'Justificatif de domicile';
      case DocumentType.rccm:
        return 'RCCM';
      case DocumentType.nif:
        return 'NIF';
      case DocumentType.bankStatement:
        return 'Relevé bancaire';
      case DocumentType.other:
        return 'Autre';
    }
  }

  String get statusLabel {
    switch (status) {
      case DocumentStatus.pending:
        return 'En attente';
      case DocumentStatus.underReview:
        return 'En cours de vérification';
      case DocumentStatus.approved:
        return 'Approuvé';
      case DocumentStatus.rejected:
        return 'Rejeté';
      case DocumentStatus.expired:
        return 'Expiré';
    }
  }
}

class KycStatusEntity {
  final String kycLevel;
  final double dailyLimit;
  final double monthlyLimit;
  final double dailyUsed;
  final double monthlyUsed;
  final List<String> requiredDocuments;
  final List<KycDocumentEntity> submittedDocuments;

  const KycStatusEntity({
    required this.kycLevel,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.dailyUsed,
    required this.monthlyUsed,
    required this.requiredDocuments,
    required this.submittedDocuments,
  });

  String get kycLevelLabel {
    switch (kycLevel) {
      case 'LEVEL_0':
        return 'Non vérifié';
      case 'LEVEL_1':
        return 'Basique';
      case 'LEVEL_2':
        return 'Standard';
      case 'LEVEL_3':
        return 'Premium';
      default:
        return kycLevel;
    }
  }

  double get dailyProgress => dailyLimit > 0 ? dailyUsed / dailyLimit : 0;
  double get monthlyProgress => monthlyLimit > 0 ? monthlyUsed / monthlyLimit : 0;
}
