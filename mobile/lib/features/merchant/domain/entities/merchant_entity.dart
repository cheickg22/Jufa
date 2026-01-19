enum MerchantType { wholesaler, retailer }

enum RelationStatus { pending, active, suspended }

class MerchantProfileEntity {
  final String id;
  final String userId;
  final String phone;
  final MerchantType merchantType;
  final String businessName;
  final String? businessCategory;
  final String? rccmNumber;
  final String? nifNumber;
  final String? address;
  final String? city;
  final double? gpsLat;
  final double? gpsLng;
  final String? logoUrl;
  final bool verified;
  final double rating;

  const MerchantProfileEntity({
    required this.id,
    required this.userId,
    required this.phone,
    required this.merchantType,
    required this.businessName,
    this.businessCategory,
    this.rccmNumber,
    this.nifNumber,
    this.address,
    this.city,
    this.gpsLat,
    this.gpsLng,
    this.logoUrl,
    required this.verified,
    required this.rating,
  });

  String get merchantTypeLabel => merchantType == MerchantType.wholesaler ? 'Grossiste' : 'Détaillant';

  String get initials {
    final words = businessName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return businessName.substring(0, 2).toUpperCase();
  }
}

class RetailerRelationEntity {
  final String id;
  final MerchantProfileEntity retailer;
  final MerchantProfileEntity wholesaler;
  final RelationStatus status;
  final double creditLimit;
  final double creditUsed;
  final double availableCredit;
  final int paymentTermsDays;
  final double discountRate;
  final DateTime? approvedAt;
  final DateTime createdAt;

  const RetailerRelationEntity({
    required this.id,
    required this.retailer,
    required this.wholesaler,
    required this.status,
    required this.creditLimit,
    required this.creditUsed,
    required this.availableCredit,
    required this.paymentTermsDays,
    required this.discountRate,
    this.approvedAt,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case RelationStatus.pending:
        return 'En attente';
      case RelationStatus.active:
        return 'Actif';
      case RelationStatus.suspended:
        return 'Suspendu';
    }
  }

  double get creditUsagePercent => creditLimit > 0 ? (creditUsed / creditLimit) * 100 : 0;
}

class MerchantDashboardEntity {
  final MerchantProfileEntity profile;
  final int activeRelations;
  final int pendingRelations;
  final double totalCreditGiven;
  final double totalCreditUsed;
  final double availableCredit;

  const MerchantDashboardEntity({
    required this.profile,
    required this.activeRelations,
    required this.pendingRelations,
    required this.totalCreditGiven,
    required this.totalCreditUsed,
    required this.availableCredit,
  });

  double get creditUsagePercent => totalCreditGiven > 0 ? (totalCreditUsed / totalCreditGiven) * 100 : 0;
}
