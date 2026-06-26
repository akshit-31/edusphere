import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._privateConstructor();
  static final CacheService instance = CacheService._privateConstructor();

  static const String _tokenKey = 'api_token';
  static const String _userKey = 'cached_user';

  late final SharedPreferences _sharedPrefs;

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _sharedPrefs;

  // Save the JWT token
  Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_tokenKey, token);
  }

  // Get the JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove the JWT token (for logout)
  Future<bool> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_tokenKey);
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
