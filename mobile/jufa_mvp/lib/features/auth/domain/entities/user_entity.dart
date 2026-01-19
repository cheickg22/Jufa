import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? email; // Email optionnel
  final String phone; // Téléphone obligatoire (identifiant principal)
  final String? profilePicture;
  final int kycLevel;
  final double balance;
  final DateTime createdAt;
  
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email, // Email optionnel
    required this.phone,
    this.profilePicture,
    required this.kycLevel,
    required this.balance,
    required this.createdAt,
  });
  
  String get fullName => '$firstName $lastName';
  
  bool get isKycVerified => kycLevel > 0;
  
  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        profilePicture,
        kycLevel,
        balance,
        createdAt,
      ];
}
