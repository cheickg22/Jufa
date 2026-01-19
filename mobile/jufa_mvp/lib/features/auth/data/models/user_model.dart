import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email, // Email optionnel
    required super.phone,
    super.profilePicture,
    required super.kycLevel,
    required super.balance,
    required super.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?, // Email optionnel
      phone: json['phone'] as String,
      profilePicture: json['profile_picture'] as String?,
      kycLevel: json['kyc_level'] as int,
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture,
      'kyc_level': kycLevel,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      profilePicture: profilePicture,
      kycLevel: kycLevel,
      balance: balance,
      createdAt: createdAt,
    );
  }
}
