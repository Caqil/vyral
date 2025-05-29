import 'package:shared_preferences/shared_preferences.dart';
import '../error/exceptions.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance =
      SharedPreferencesHelper._internal();
  factory SharedPreferencesHelper() => _instance;
  SharedPreferencesHelper._internal();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw CacheException(
          message: 'Failed to get string from preferences: $e');
    }
  }

  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to set string in preferences: $e');
    }
  }

  // Int operations
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw CacheException(message: 'Failed to get int from preferences: $e');
    }
  }

  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to set int in preferences: $e');
    }
  }

  // Bool operations
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException(message: 'Failed to get bool from preferences: $e');
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to set bool in preferences: $e');
    }
  }

  // Double operations
  Future<double?> getDouble(String key) async {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      throw CacheException(
          message: 'Failed to get double from preferences: $e');
    }
  }

  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to set double in preferences: $e');
    }
  }

  // StringList operations
  Future<List<String>?> getStringList(String key) async {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      throw CacheException(
          message: 'Failed to get string list from preferences: $e');
    }
  }

  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      throw CacheException(
          message: 'Failed to set string list in preferences: $e');
    }
  }

  // Remove operations
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      throw CacheException(message: 'Failed to remove from preferences: $e');
    }
  }

  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear preferences: $e');
    }
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}
