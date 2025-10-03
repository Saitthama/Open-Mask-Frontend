import 'package:open_mask/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './snackbar_service.dart';

// TODO: vielleicht eher in Auth Service integrieren
class AutomaticLoginService {
  static bool _rememberMe = false;

  static bool get rememberMe => _rememberMe;

  /// Login-Daten lokal speichern
  static Future<void> saveLoginData(
      final String email, final String password) async {
    _rememberMe = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', _rememberMe);
  }

  /// Lokale Login-Daten löschen
  static Future<void> clearLoginData() async {
    _rememberMe = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    await prefs.setString('email', '');
    await prefs.setString('password', '');
  }

  /// Automatisches Login
  static Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    if (_rememberMe) {
      String email = prefs.getString('email') ?? '';
      String password = prefs.getString('password') ?? '';
      bool success = await AuthService.login(email, password);
      //-> login Seite
      // am Besten über Routing
      // (z.B. Loading/Starting Screen (route: "/") machen,
      // als Initial-Route setzen
      // und von dort aus weiternavigieren je nachdem, was rememberMe ist)
      if (!success) {
        clearLoginData();
        return;
      }
      SnackBarService.showMessage("Automatisch eingeloggt");
    }
  }
}
