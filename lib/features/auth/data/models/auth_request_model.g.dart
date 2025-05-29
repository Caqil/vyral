// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      emailOrUsername: json['email_or_username'] as String,
      password: json['password'] as String,
      deviceInfo: json['device_info'] as String?,
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{
      'email_or_username': instance.emailOrUsername,
      'password': instance.password,
      'device_info': instance.deviceInfo,
    };

RegisterRequestModel _$RegisterRequestModelFromJson(
        Map<String, dynamic> json) =>
    RegisterRequestModel(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
        RegisterRequestModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'phone': instance.phone,
    };

RefreshTokenRequestModel _$RefreshTokenRequestModelFromJson(
        Map<String, dynamic> json) =>
    RefreshTokenRequestModel(
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestModelToJson(
        RefreshTokenRequestModel instance) =>
    <String, dynamic>{
      'refresh_token': instance.refreshToken,
    };

ForgotPasswordRequestModel _$ForgotPasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequestModel(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ForgotPasswordRequestModelToJson(
        ForgotPasswordRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

ResetPasswordRequestModel _$ResetPasswordRequestModelFromJson(
        Map<String, dynamic> json) =>
    ResetPasswordRequestModel(
      token: json['token'] as String,
      newPassword: json['new_password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );

Map<String, dynamic> _$ResetPasswordRequestModelToJson(
        ResetPasswordRequestModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'new_password': instance.newPassword,
      'confirm_password': instance.confirmPassword,
    };

VerifyEmailRequestModel _$VerifyEmailRequestModelFromJson(
        Map<String, dynamic> json) =>
    VerifyEmailRequestModel(
      token: json['token'] as String,
    );

Map<String, dynamic> _$VerifyEmailRequestModelToJson(
        VerifyEmailRequestModel instance) =>
    <String, dynamic>{
      'token': instance.token,
    };
