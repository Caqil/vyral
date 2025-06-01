// Updated lib/features/auth/data/datasources/auth_local_datasource.dart

import 'dart:convert';
import 'package:vyral/core/utils/logger.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/storage_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<void> clearAuthData();

  // New methods for refresh time tracking
  Future<void> storeLastRefreshTime();
  Future<DateTime?> getLastRefreshTime();
  Future<void> clearLastRefreshTime();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) async {
    await Future.wait([
      _secureStorage.write(StorageConstants.accessToken, accessToken),
      _secureStorage.write(StorageConstants.refreshToken, refreshToken),
      _secureStorage.write(StorageConstants.userId, user.id),
      _secureStorage.write(StorageConstants.userEmail, user.email),
      _secureStorage.write(StorageConstants.userName, user.username),
      _secureStorage.write('user_data', jsonEncode(user.toJson())),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(StorageConstants.accessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(StorageConstants.refreshToken);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userDataString = await _secureStorage.read('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    }
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  @override
  Future<void> clearAuthData() async {
    await Future.wait([
      _secureStorage.delete(StorageConstants.accessToken),
      _secureStorage.delete(StorageConstants.refreshToken),
      _secureStorage.delete(StorageConstants.userId),
      _secureStorage.delete(StorageConstants.userEmail),
      _secureStorage.delete(StorageConstants.userName),
      _secureStorage.delete('user_data'),
    ]);
  }

  // New methods for refresh time tracking
  @override
  Future<void> storeLastRefreshTime() async {
    try {
      await _secureStorage.write(
        StorageConstants.lastTokenRefresh,
        DateTime.now().toIso8601String(),
      );
      AppLogger.debug('✅ Stored last refresh time');
    } catch (e) {
      AppLogger.debug('❌ Failed to store refresh time: $e');
      throw e;
    }
  }

  @override
  Future<DateTime?> getLastRefreshTime() async {
    try {
      final lastRefreshString =
          await _secureStorage.read(StorageConstants.lastTokenRefresh);
      if (lastRefreshString != null) {
        return DateTime.parse(lastRefreshString);
      }
      return null;
    } catch (e) {
      AppLogger.debug('❌ Failed to get last refresh time: $e');
      return null;
    }
  }

  @override
  Future<void> clearLastRefreshTime() async {
    try {
      await _secureStorage.delete(StorageConstants.lastTokenRefresh);
      AppLogger.debug('🧹 Cleared last refresh time');
    } catch (e) {
      AppLogger.debug('❌ Failed to clear refresh time: $e');
    }
  }
}
