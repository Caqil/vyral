import 'dart:convert';
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
}
