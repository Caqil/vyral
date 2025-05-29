// lib/core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../error/exceptions.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  static late FlutterSecureStorage _storage;

  static Future<void> init() async {
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    );
    
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    );

    _storage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
  }

  /// Read data from secure storage
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to read from secure storage: $e');
    }
  }

  /// Write data to secure storage
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw CacheException(message: 'Failed to write to secure storage: $e');
    }
  }

  /// Delete data from secure storage
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete from secure storage: $e');
    }
  }

  /// Check if key exists in secure storage
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to check key in secure storage: $e');
    }
  }

  /// Get all keys from secure storage
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw CacheException(message: 'Failed to read all from secure storage: $e');
    }
  }

  /// Clear all data from secure storage
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException(message: 'Failed to clear secure storage: $e');
    }
  }
}
