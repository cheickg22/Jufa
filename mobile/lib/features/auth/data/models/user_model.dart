import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String userType;
  final String status;
  final String kycLevel;
  
  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.userType,
    required this.status,
    required this.kycLevel,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final UserModel? user;
  
  const AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    this.user,
  });
  
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

@JsonSerializable()
class RegisterResponseModel {
  final String userId;
  final String phone;
  final String message;
  
  const RegisterResponseModel({
    required this.userId,
    required this.phone,
    required this.message,
  });
  
  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) => _$RegisterResponseModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$RegisterResponseModelToJson(this);
}
