import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  static SharedPreferences get instance => _preferences;
  static late final SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
}