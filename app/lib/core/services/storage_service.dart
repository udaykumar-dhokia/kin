import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  static bool hasSeenOnboarding() {
    return _prefs?.getBool(AppConstants.keyHasSeenOnboarding) ?? false;
  }

  static Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs?.setBool(AppConstants.keyHasSeenOnboarding, value);
  }

  // Auth tokens
  static String? getAuthToken() {
    return _prefs?.getString(AppConstants.keyAuthToken);
  }

  static Future<void> setAuthToken(String token) async {
    await _prefs?.setString(AppConstants.keyAuthToken, token);
  }

  static String? getRefreshToken() {
    return _prefs?.getString(keyRefreshToken);
  }

  static Future<void> setRefreshToken(String token) async {
    await _prefs?.setString(keyRefreshToken, token);
  }

  static bool isLoggedIn() {
    final token = getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // User Profile
  static Map<String, dynamic>? getUserData() {
    final raw = _prefs?.getString(keyUserData);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setUserData(Map<String, dynamic> userMap) async {
    await _prefs?.setString(keyUserData, jsonEncode(userMap));
  }

  // Clear session
  static Future<void> clearAuth() async {
    await _prefs?.remove(AppConstants.keyAuthToken);
    await _prefs?.remove(keyRefreshToken);
    await _prefs?.remove(keyUserData);
  }
}
