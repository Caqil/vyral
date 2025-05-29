import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../storage/secure_storage.dart';
import '../../constants/storage_constants.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage = SecureStorage();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for certain endpoints
    if (_shouldSkipAuth(options.path)) {
      return handler.next(options);
    }

    // Get access token from secure storage
    final accessToken = await _secureStorage.read(StorageConstants.accessToken);

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh on 401 errors
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken =
            await _secureStorage.read(StorageConstants.refreshToken);

        if (refreshToken != null) {
          // Try to refresh token
          final newTokens = await _refreshToken(refreshToken);

          if (newTokens != null) {
            // Save new tokens
            await _secureStorage.write(
                StorageConstants.accessToken, newTokens['access_token']);
            if (newTokens['refresh_token'] != null) {
              await _secureStorage.write(
                  StorageConstants.refreshToken, newTokens['refresh_token']);
            }

            // Retry original request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] =
                'Bearer ${newTokens['access_token']}';

            try {
              final response = await Dio().fetch(options);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(err);
            }
          }
        }

        // Clear tokens and redirect to login
        await _clearTokensAndRedirect();
      } catch (e) {
        await _clearTokensAndRedirect();
      }
    }

    handler.next(err);
  }

  bool _shouldSkipAuth(String path) {
    const skipAuthPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/verify-email',
      '/auth/check-user',
      '/health',
      '/status',
      '/version',
    ];

    return skipAuthPaths.any((skipPath) => path.contains(skipPath));
  }

  Future<Map<String, dynamic>?> _refreshToken(String refreshToken) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.refresh}',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      // Refresh failed
    }
    return null;
  }

  Future<void> _clearTokensAndRedirect() async {
    await _secureStorage.delete(StorageConstants.accessToken);
    await _secureStorage.delete(StorageConstants.refreshToken);
    await _secureStorage.delete(StorageConstants.userId);
    await _secureStorage.delete(StorageConstants.userEmail);

    // TODO: Navigate to login page
    // This would typically be handled by a navigation service or auth bloc
  }
}
