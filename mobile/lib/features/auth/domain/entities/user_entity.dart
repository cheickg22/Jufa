import 'package:equatable/equatable.dart';

enum UserType { 
  individual,   // Particulier (B2C)
  wholesaler,   // Grossiste (B2B Fournisseur)
  retailer,     // Détaillant / Boutiquier
  agent,        // Agent JUFA
  merchant,     // Commerçant générique (legacy)
  admin,        // Administrateur JUFA
  bankAdmin,    // Administrateur Banque Partenaire
  superAdmin,   // Super Administrateur
}

enum UserStatus { pending, active, suspended, blocked }
enum KycLevel { level0, level1, level2, level3 }

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String? email;
  final UserType userType;
  final UserStatus status;
  final KycLevel kycLevel;
  
  const UserEntity({
    required this.id,
    required this.phone,
    this.email,
    required this.userType,
    required this.status,
    required this.kycLevel,
  });
  
  bool get isActive => status == UserStatus.active;
  
  bool get isMerchant => userType == UserType.merchant || 
                         userType == UserType.wholesaler || 
                         userType == UserType.retailer;
  
  bool get isWholesaler => userType == UserType.wholesaler;
  
  bool get isRetailer => userType == UserType.retailer;
  
  bool get isAgent => userType == UserType.agent;
  
  bool get isIndividual => userType == UserType.individual;
  
  String get displayName => email ?? phone;
  
  @override
  List<Object?> get props => [id, phone, email, userType, status, kycLevel];
}

class RegisterResult extends Equatable {
  final String userId;
  final String phone;
  final String message;
  
  const RegisterResult({
    required this.userId,
    required this.phone,
    required this.message,
  });
  
  @override
  List<Object> get props => [userId, phone, message];
}
