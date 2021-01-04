import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String userDataKey = 'userDataKey';
  static const String tokenKey = 'tokenKey';
  static const String userIdKey = 'userIdKey';
  static const String expiryDateKey = 'expiryDateKey';

  static void addToPreferences(String key, data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  static Future<String> get tryAutoLogin async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(userDataKey) ? prefs.getString(userDataKey) : null;
  }

  static Future<void> clearAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(userDataKey);
  }
}
