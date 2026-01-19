import '../../domain/entities/merchant_entity.dart';

class MerchantProfileModel extends MerchantProfileEntity {
  const MerchantProfileModel({
    required super.id,
    required super.userId,
    required super.phone,
    required super.merchantType,
    required super.businessName,
    super.businessCategory,
    super.rccmNumber,
    super.nifNumber,
    super.address,
    super.city,
    super.gpsLat,
    super.gpsLng,
    super.logoUrl,
    required super.verified,
    required super.rating,
  });

  factory MerchantProfileModel.fromJson(Map<String, dynamic> json) {
    return MerchantProfileModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      phone: json['phone'] ?? '',
      merchantType: _parseMerchantType(json['merchantType']),
      businessName: json['businessName'] ?? '',
      businessCategory: json['businessCategory'],
      rccmNumber: json['rccmNumber'],
      nifNumber: json['nifNumber'],
      address: json['address'],
      city: json['city'],
      gpsLat: (json['gpsLat'] as num?)?.toDouble(),
      gpsLng: (json['gpsLng'] as num?)?.toDouble(),
      logoUrl: json['logoUrl'],
      verified: json['verified'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static MerchantType _parseMerchantType(String? type) {
    switch (type) {
      case 'WHOLESALER':
        return MerchantType.wholesaler;
      case 'RETAILER':
        return MerchantType.retailer;
      default:
        return MerchantType.retailer;
    }
  }

  static String merchantTypeToString(MerchantType type) {
    switch (type) {
      case MerchantType.wholesaler:
        return 'WHOLESALER';
      case MerchantType.retailer:
        return 'RETAILER';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantType': merchantTypeToString(merchantType),
      'businessName': businessName,
      'businessCategory': businessCategory,
      'rccmNumber': rccmNumber,
      'nifNumber': nifNumber,
      'address': address,
      'city': city,
      'gpsLat': gpsLat,
      'gpsLng': gpsLng,
    };
  }
}

class RetailerRelationModel extends RetailerRelationEntity {
  const RetailerRelationModel({
    required super.id,
    required super.retailer,
    required super.wholesaler,
    required super.status,
    required super.creditLimit,
    required super.creditUsed,
    required super.availableCredit,
    required super.paymentTermsDays,
    required super.discountRate,
    super.approvedAt,
    required super.createdAt,
  });

  factory RetailerRelationModel.fromJson(Map<String, dynamic> json) {
    return RetailerRelationModel(
      id: json['id'] ?? '',
      retailer: MerchantProfileModel.fromJson(json['retailer']),
      wholesaler: MerchantProfileModel.fromJson(json['wholesaler']),
      status: _parseRelationStatus(json['status']),
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      creditUsed: (json['creditUsed'] as num?)?.toDouble() ?? 0.0,
      availableCredit: (json['availableCredit'] as num?)?.toDouble() ?? 0.0,
      paymentTermsDays: json['paymentTermsDays'] ?? 0,
      discountRate: (json['discountRate'] as num?)?.toDouble() ?? 0.0,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  static RelationStatus _parseRelationStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return RelationStatus.pending;
      case 'ACTIVE':
        return RelationStatus.active;
      case 'SUSPENDED':
        return RelationStatus.suspended;
      default:
        return RelationStatus.pending;
    }
  }
}

class MerchantDashboardModel extends MerchantDashboardEntity {
  const MerchantDashboardModel({
    required super.profile,
    required super.activeRelations,
    required super.pendingRelations,
    required super.totalCreditGiven,
    required super.totalCreditUsed,
    required super.availableCredit,
  });

  factory MerchantDashboardModel.fromJson(Map<String, dynamic> json) {
    return MerchantDashboardModel(
      profile: MerchantProfileModel.fromJson(json['profile']),
      activeRelations: json['activeRelations'] ?? 0,
      pendingRelations: json['pendingRelations'] ?? 0,
      totalCreditGiven: (json['totalCreditGiven'] as num?)?.toDouble() ?? 0.0,
      totalCreditUsed: (json['totalCreditUsed'] as num?)?.toDouble() ?? 0.0,
      availableCredit: (json['availableCredit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
