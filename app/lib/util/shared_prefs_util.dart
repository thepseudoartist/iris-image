import 'package:shared_preferences/shared_preferences.dart';

//* Shared Preferences helper to store user settings.
class SharedPrefsUtil {
  SharedPrefsUtil._();

  static Future<String> getBaseUrl() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('BASE_URL');
  }

  static Future<void> setBaseUrl(String url) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('BASE_URL', url);
  }
}