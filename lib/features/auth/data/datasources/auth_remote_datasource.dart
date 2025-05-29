import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/models/api_response.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<AuthResponseModel> refreshToken(RefreshTokenRequestModel request);
  Future<void> logout();
  Future<void> logoutFromAllSessions();
  Future<void> forgotPassword(ForgotPasswordRequestModel request);
  Future<void> resetPassword(ResetPasswordRequestModel request);
  Future<void> verifyEmail(VerifyEmailRequestModel request);
  Future<List<SessionModel>> getUserSessions();
  Future<void> revokeSession(String sessionId);
  Future<bool> checkUserExists({String? username, String? email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Your API returns data in nested structure
        return AuthResponseModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return AuthResponseModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(
      RefreshTokenRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.refresh,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return AuthResponseModel.fromJson(apiResponse.data!);
      } else {
        throw Exception(apiResponse.message ?? 'Token refresh failed');
      }
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await _dioClient.post(ApiConstants.logout);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Logout failed');
      }
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<void> logoutFromAllSessions() async {
    try {
      final response = await _dioClient.post(ApiConstants.logoutAll);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(
            apiResponse.message ?? 'Logout from all sessions failed');
      }
    } catch (e) {
      throw Exception('Logout from all sessions failed: $e');
    }
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.forgotPassword,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(
            apiResponse.message ?? 'Forgot password request failed');
      }
    } catch (e) {
      throw Exception('Forgot password request failed: $e');
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.resetPassword,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Password reset failed');
      }
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  Future<void> verifyEmail(VerifyEmailRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.verifyEmail,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Email verification failed');
      }
    } catch (e) {
      throw Exception('Email verification failed: $e');
    }
  }

  @override
  Future<List<SessionModel>> getUserSessions() async {
    try {
      final response = await _dioClient.get(ApiConstants.sessions);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((session) =>
                SessionModel.fromJson(session as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(apiResponse.message ?? 'Failed to get user sessions');
      }
    } catch (e) {
      throw Exception('Failed to get user sessions: $e');
    }
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    try {
      final response = await _dioClient.delete(
        '${ApiConstants.sessions}/$sessionId',
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.message ?? 'Failed to revoke session');
      }
    } catch (e) {
      throw Exception('Failed to revoke session: $e');
    }
  }

  @override
  Future<bool> checkUserExists({String? username, String? email}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (username != null) queryParams['username'] = username;
      if (email != null) queryParams['email'] = email;

      final response = await _dioClient.get(
        ApiConstants.checkUser,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!['exists'] as bool? ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
