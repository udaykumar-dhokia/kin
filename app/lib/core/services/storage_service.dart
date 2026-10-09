import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool hasSeenOnboarding() {
    return _prefs?.getBool(AppConstants.keyHasSeenOnboarding) ?? false;
  }

  static Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs?.setBool(AppConstants.keyHasSeenOnboarding, value);
  }

  static String? getAuthToken() {
    return _prefs?.getString(AppConstants.keyAuthToken);
  }

  static Future<void> setAuthToken(String token) async {
    await _prefs?.setString(AppConstants.keyAuthToken, token);
  }

  static Future<void> clearAuthToken() async {
    await _prefs?.remove(AppConstants.keyAuthToken);
  }
}
