import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheService {
  CacheService._privateConstructor();
  static final CacheService instance = CacheService._privateConstructor();

  static const String _tokenKey = 'api_token';
  static const String _userKey = 'cached_user';
  
  static const _secureStorage = FlutterSecureStorage();

  late final SharedPreferences _sharedPrefs;

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _sharedPrefs;

  // Save the JWT token securely using FlutterSecureStorage
  Future<bool> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Get the JWT token securely from FlutterSecureStorage
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  // Remove the JWT token (for logout) securely
  Future<bool> removeToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Save the complete User object
  Future<bool> saveUser(Map<String, dynamic> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(userMap);
    return prefs.setString(_userKey, userJson);
  }

  // Get the complete User object
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null || userJson.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(userJson) as Map);
    } catch (_) {
      return null;
    }
  }

  // Update specific fields on the cached user object
  Future<bool> updateUser(Map<String, dynamic> updatedFields) async {
    final currentUser = await getUser();
    if (currentUser == null) return false;
    
    // Merge new fields
    currentUser.addAll(updatedFields);
    return saveUser(currentUser);
  }

  // Clear all cache (useful for logout)
  Future<void> clearAll() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Generic key-value helpers
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, value);
  }

  Future<bool> clear() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
