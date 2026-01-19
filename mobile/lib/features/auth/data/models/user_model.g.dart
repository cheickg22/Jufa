// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      userType: json['userType'] as String,
      status: json['status'] as String,
      kycLevel: json['kycLevel'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'email': instance.email,
      'userType': instance.userType,
      'status': instance.status,
      'kycLevel': instance.kycLevel,
    };

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: (json['expiresIn'] as num).toInt(),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'user': instance.user?.toJson(),
    };

RegisterResponseModel _$RegisterResponseModelFromJson(
        Map<String, dynamic> json) =>
    RegisterResponseModel(
      userId: json['userId'] as String,
      phone: json['phone'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RegisterResponseModelToJson(
        RegisterResponseModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'phone': instance.phone,
      'message': instance.message,
    };
