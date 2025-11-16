import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:open_mask/data/repositories/auth_repository.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/ui/widgets/form_header_text.dart';

// TODO: Umstellen auf Java Backend
// TODO: nicht static machen und Anmeldedaten etc. speichern
class AuthService {
  /// Meldet den Benutzer an und überprüft, ob die E-Mail verifiziert wurde. Liefert true zurück, wenn die Anmeldung erfolgreich war.
  static Future<bool> login(final String email, final String password) async {
    var url = Uri.https(
      'openmask.fabianmild.dev',
      '/api/notauth/login',
      {
        'email': email,
        'password': password,
      },
    );
    try {
      var response = await http.get(url);
      if (response.statusCode != 200) {
        SnackBarService.showMessage('Email oder Passwort ist falsch!');
        return false;
      }
      SnackBarService.showMessage('Du bist eingelogt');
      return true;
    } catch (e) {
      SnackBarService.showMessage('Error: ${e.toString()}');
      return false;
    }
  }

  static Future<bool> loginFirebase(
      final String email, final String password) async {
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

  /// Registriert den Benutzer

  static Future<bool> register(final String email, final String password,
      final String username, final String name) async {
    var url = Uri.https('openmask.fabianmild.dev', '/api/notauth/register');
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

  static Future<bool> registerFirebase(final String email,
      final String password, final String username, final String name) async {
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



  static Future<void> deleteAccount(BuildContext context) async {
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
}
