import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/storage_constants.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  static late Box _cacheBox;

  static Future<void> init() async {
    _cacheBox = await Hive.openBox(StorageConstants.cacheBox);
  }

  /// Cache data with expiration
  Future<void> cacheData(
    String key,
    Map<String, dynamic> data, {
    Duration? expiration,
  }) async {
    try {
      final cacheItem = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiration': expiration?.inMilliseconds,
      };

      await _cacheBox.put(key, jsonEncode(cacheItem));
    } catch (e) {
      throw CacheException(message: 'Failed to cache data: $e');
    }
  }

  /// Get cached data if not expired
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final cachedString = _cacheBox.get(key);
      if (cachedString == null) return null;

      final cacheItem = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheItem['timestamp'] as int;
      final expiration = cacheItem['expiration'] as int?;

      // Check if expired
      if (expiration != null) {
        final expiryTime = timestamp + expiration;
        if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
          await _cacheBox.delete(key);
          return null;
        }
      }

      return cacheItem['data'] as Map<String, dynamic>;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached data: $e');
    }
  }

  /// Cache list data with expiration
  Future<void> cacheListData(
    String key,
    List<Map<String, dynamic>> data, {
    Duration? expiration,
  }) async {
    try {
      final cacheItem = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiration': expiration?.inMilliseconds,
      };

      await _cacheBox.put(key, jsonEncode(cacheItem));
    } catch (e) {
      throw CacheException(message: 'Failed to cache list data: $e');
    }
  }

  /// Get cached list data if not expired
  Future<List<Map<String, dynamic>>?> getCachedListData(String key) async {
    try {
      final cachedString = _cacheBox.get(key);
      if (cachedString == null) return null;

      final cacheItem = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheItem['timestamp'] as int;
      final expiration = cacheItem['expiration'] as int?;

      // Check if expired
      if (expiration != null) {
        final expiryTime = timestamp + expiration;
        if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
          await _cacheBox.delete(key);
          return null;
        }
      }

      final data = cacheItem['data'] as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached list data: $e');
    }
  }

  /// Remove cached data
  Future<void> removeCachedData(String key) async {
    try {
      await _cacheBox.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to remove cached data: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      await _cacheBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final keys = _cacheBox.keys.toList();
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      for (final key in keys) {
        final cachedString = _cacheBox.get(key);
        if (cachedString != null) {
          final cacheItem = jsonDecode(cachedString) as Map<String, dynamic>;
          final timestamp = cacheItem['timestamp'] as int;
          final expiration = cacheItem['expiration'] as int?;

          if (expiration != null) {
            final expiryTime = timestamp + expiration;
            if (currentTime > expiryTime) {
              await _cacheBox.delete(key);
            }
          }
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear expired cache: $e');
    }
  }

  /// Get cache size in bytes
  int getCacheSize() {
    try {
      final keys = _cacheBox.keys;
      int totalSize = 0;

      for (final key in keys) {
        final value = _cacheBox.get(key);
        if (value is String) {
          totalSize += value.length;
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Check if cache exists and is not expired
  Future<bool> isCacheValid(String key) async {
    try {
      final cachedString = _cacheBox.get(key);
      if (cachedString == null) return false;

      final cacheItem = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheItem['timestamp'] as int;
      final expiration = cacheItem['expiration'] as int?;

      if (expiration != null) {
        final expiryTime = timestamp + expiration;
        return DateTime.now().millisecondsSinceEpoch <= expiryTime;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cache with default expiration times
  Future<void> cacheWithShortExpiration(
      String key, Map<String, dynamic> data) async {
    await cacheData(key, data, expiration: AppConstants.cacheShortDuration);
  }

  Future<void> cacheWithMediumExpiration(
      String key, Map<String, dynamic> data) async {
    await cacheData(key, data, expiration: AppConstants.cacheMediumDuration);
  }

  Future<void> cacheWithLongExpiration(
      String key, Map<String, dynamic> data) async {
    await cacheData(key, data, expiration: AppConstants.cacheLongDuration);
  }
}
