import 'package:json_annotation/json_annotation.dart';

part 'auth_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  @JsonKey(name: 'email_or_username')
  final String emailOrUsername;
  final String password;
  @JsonKey(name: 'device_info')
  final String? deviceInfo;

  const LoginRequestModel({
    required this.emailOrUsername,
    required this.password,
    this.deviceInfo,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}

@JsonSerializable()
class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'display_name')
  final String? displayName;
  final String? bio;
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phone;

  const RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.displayName,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.phone,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}

@JsonSerializable()
class RefreshTokenRequestModel {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const RefreshTokenRequestModel({required this.refreshToken});

  factory RefreshTokenRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestModelToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequestModel {
  final String email;

  const ForgotPasswordRequestModel({required this.email});

  factory ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestModelToJson(this);
}

@JsonSerializable()
class ResetPasswordRequestModel {
  final String token;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  const ResetPasswordRequestModel({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestModelToJson(this);
}

@JsonSerializable()
class VerifyEmailRequestModel {
  final String token;

  const VerifyEmailRequestModel({required this.token});

  factory VerifyEmailRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestModelToJson(this);
}
