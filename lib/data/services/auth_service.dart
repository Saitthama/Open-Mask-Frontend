import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_mask/data/constants.dart';
import 'package:open_mask/data/model/user.dart';
import 'package:open_mask/data/services/automatic_login_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/filter_store.dart';

/// Service zur Durchführung von Authentifizierungsoperationen wie Registrierung und Anmeldung.
class AuthService extends ChangeNotifier {
  /// Privater Konstruktor für das Singleton-Pattern.
  AuthService._internal();

  /// Singleton-Instanz.
  static final AuthService instance = AuthService._internal();

  /// Gibt an, ob ein Benutzer eingeloggt ist.
  bool _loggedIn = false;

  /// Gibt an, ob ein Benutzer eingeloggt ist.
  bool get loggedIn => _loggedIn;

  /// Usermodel des Users.
  User? _user;

  /// Aktuell eingeloggter [User].
  User? get user => _user;

  /// Meldet den Benutzer an und überprüft, ob die E-Mail verifiziert wurde. Liefert true zurück, wenn die Anmeldung erfolgreich war.
  Future<bool> login(final String email, final String password) async {
    var url = Uri.https(
      apiBaseUrl,
      '$notAuth/login',
    );
    bool success = false;
    try {
      var response = await http.get(
        url,
        headers: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 404) {
        SnackBarService.showMessage('User existiert nicht');
        return false;
      }
      if (response.statusCode == 401) {
        SnackBarService.showMessage('Passwort ist falsch!');
        return false;
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      _user = User.fromJson(data);
      success = true;

      _loggedIn = success;
      notifyListeners();
      FilterStore.instance
          .initialize(); // asynchron im Hintergrund die Filter initialisieren
      return success;
    } catch (e) {
      SnackBarService.showMessage('Fehler: $e');
      return false;
    }
  }

  /// Meldet den Benutzer ab.
  /// Dafür wird das Property [user] gecleared, [loggedIn] auf false gesetzt,
  /// [notifyListeners] zur Benachrichtigung der Änderungen aufgerufen und das Logout im Backend gemeldet.
  /// Außerdem werden die Nutzerdaten aus dem [AutomaticLoginService] gelöscht.
  Future<bool> logout() async {
    _loggedIn = false;
    _user = null;
    FilterStore.instance.clear();
    AutomaticLoginService.instance.clearLoginData();
    notifyListeners();
    // TODO: implement backend communication
    return !_loggedIn;
  }

/*
  Future<bool> loginFirebase(final String email, final String password) async {
    UserCredential userCredential;
    try {
      userCredential = await AuthRepository.signIn(email, password);
    } catch (e) {
      SnackBarService.showMessage('Error: ${e.toString()}');
      return false;
    }

    // Überprüfen, ob die E-Mail schon verifiziert wurde
    if (userCredential.user!.emailVerified) {
      return true;
    }
    // Verifizierungs-E-Mail erneut senden
    await AuthRepository.sendEmailVerification(userCredential);

    await AuthRepository.signOut();

    SnackBarService.showMessage(
        'E-Mail wurde noch nicht verifiziert! \nBitte überprüfen Sie ihren Posteingang!');
    return false;
  }
  
 */

  /// Registriert den Benutzer
  Future<bool> register(final String email, final String password,
      final String username, final String name) async {
    var url = Uri.https(apiBaseUrl, '$notAuth/register');
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
          'name': name,
        }),
      );
      SnackBarService.showMessage('Registrierung erfolgreich!');
      return true;
    } catch (e) {
      SnackBarService.showMessage('Fehler: ${e.toString()}');
      return false;
    }
  }
/*
  Future<bool> registerFirebase(final String email, final String password,
      final String username, final String name) async {
    try {
      // Benutzer erstellen
      UserCredential userCredential =
          await AuthRepository.createUser(email, password, username, name);

      // E-Mail-Verifizierungslink senden
      await AuthRepository.sendEmailVerification(userCredential);

      // Benutzer abmelden, bis er verifiziert ist
      await AuthRepository.signOut();

      // Bestätigung und Anforderung zur verifizierung anzeigen
      SnackBarService.showMessage(
          'Registrierung erfolgreich! \nBitte überprüfen Sie Ihr Postfach, um Ihre E-Mail zu verifizieren!');

      return true;
    } catch (e) {
      SnackBarService.showMessage('Fehler: ${e.toString()}');
      return false;
    }
  }
  


  Future<void> deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Account Löschen bestätigen"),
            content: Text(
                "Sind sie sich sicher das sie ihr Konto löschen möchten? Diese Aktion kann nicht rünkgängig gemacht werden."),
            actions: [
              TextButton(
                onPressed: () => ctx.pop(false),
                child: Text("Abbrechen"),
              ),
              TextButton(
                onPressed: () => ctx.pop(true),
                child: Text("Löschen", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (shouldDelete == true) {
          await user.delete();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            'The user must reauthenticate before this operation can be executed.');
      } else {
        print('Error: ${e.message}');
      }
    }
  }
  
 */
}
