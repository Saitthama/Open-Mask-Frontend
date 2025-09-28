import 'package:shared_preferences/shared_preferences.dart';

import './snackbar_service.dart';

class AutomaticLoginService {
  static bool _rememberMe = false;

  static bool get rememberMe => _rememberMe;

  // Login daten werden gespeichert wenn das hackerl gesetzt ist
  static Future<void> saveLoginData(email, password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', true);
    _rememberMe = true;
    if (_rememberMe == true) {
      SnackBarService.showMessage("du bleibst eingelogt");
    }
  }

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _rememberMe = false;
  }

  static Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('_remeberMe') ?? false;
    if (rememberMe) {
      //-> login Seite
      _rememberMe = true;
    }
    SnackBarService.showMessage("hier werden sachen gemacht");
  }
}
