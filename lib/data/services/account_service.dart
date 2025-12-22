import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:open_mask/data/constants.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/ui/widgets/form_header_text.dart';

/// Service zur Durchführung von Konto-Operationen
/// wie dem Bearbeiten von Attributen oder dem Löschen des Accounts.
class AccountService {
  static Future<void> editName(final BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      SnackBarService.showMessage('Kein Benutzer eingeloggt!');
      return;
    }

    String userId = user.uid;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();

    if (!userDoc.exists) {
      SnackBarService.showMessage('Benutzerdaten nicht gefunden!');
      return;
    }

    String currentName = userDoc['name'] ?? '';
    TextEditingController nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Benutzer bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Neuen Namen eingeben'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                await FirebaseFirestore.instance
                    .collection("User")
                    .doc(userId)
                    .update({
                  "name": newName,
                });
                context.pop();
                SnackBarService.showMessage("Name erfolgreich aktualisiert!");
              },
              child: Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  static Future<void> editUsername(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      SnackBarService.showMessage("Kein Benutzer eingeloggt!");
      return;
    }

    String userId = user.uid;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("User").doc(userId).get();

    if (!userDoc.exists) {
      SnackBarService.showMessage("Benutzerdaten nicht gefunden!");
      return;
    }

    String currentUsername = userDoc["username"] ?? "";
    TextEditingController usernameController =
        TextEditingController(text: currentUsername);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Benutzer bearbeiten"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration:
                    InputDecoration(labelText: "Neuen Benutzernamen eingeben"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newUsername = usernameController.text.trim();
                await FirebaseFirestore.instance
                    .collection("User")
                    .doc(userId)
                    .update({
                  "username": newUsername,
                });
                SnackBarService.showMessage(
                    "Benutzernamen erfolgreich aktualisiert!");
                context.pop();
              },
              child: Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  static Future<void> resetEmail(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user == null) {
      SnackBarService.showMessage("Kein Benutzer eingeloggt!");
      return;
    }

    String userId = user.uid;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("E-Mail-Adresse ändern"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Neue E-Mail-Adresse"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () async {
              String newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty) {
                try {
                  await user.verifyBeforeUpdateEmail(newEmail);
                  await FirebaseFirestore.instance
                      .collection("User")
                      .doc(userId)
                      .update({
                    "email": newEmail,
                  });

                  context.pop();
                  SnackBarService.showMessage("Bestätigungs-E-Mail gesendet!");
                } catch (e) {
                  SnackBarService.showMessage("Fehler: ${e.toString()}");
                }
              }
            },
            child: Text("E-Mail ändern"),
          ),
        ],
      ),
    );
  }

  static Future<void> resetPassword(BuildContext context) async {
    /* TODO: löschen
    // wir wollen eigentlich gar nicht angemeldet sein müssen
    // User und userID holen:
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user == null) {
      SnackBarService.showMessage("Kein Benutzer eingeloggt!");
      return;
    }

    if (user.email == null) {
      SnackBarService.showMessage("Keine E-Mail gefunden!");
      return;
    }
    */

    // Password Reset Dialog:
    /* TODO: löschen
    // Manuell in der App das Passwort zurücksetzen
    bool resetLinkSent = false;
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    */
    final passwordResetFormKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Passwort zurücksetzen"),
        content: SingleChildScrollView(
          child: Form(
            key: passwordResetFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormHeaderText(
                    "Bitte geben Sie ihre E-Mail-Adresse ein, um ihr Passwort zurückzusetzen."),
                const SizedBox(height: 5),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "E-Mail-Adresse"),
                  validator: (value) {
                    return (value == null ||
                            value.isEmpty ||
                            !value.contains('@'))
                        ? 'Bitte gültige E-Mail eingeben'
                        : null;
                    // TODO: löschen (man sollte nicht angemeldet sein müssen)
                    // return (value != user.email) ? "Stimmt nicht mit der Benutzer-E-Mail überein!" : null;
                  },
                ),

                /* TODO: löschen
                // Manuell in der App das Passwort zurücksetzen
                // Passwort eingeben
                const SizedBox(height: 3),
                TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: "Neues Passwort"),
                    validator: (value) {
                      return (value == null || value.length < 6) ? "Passwort muss mindestens 6 Zeichen haben" : null;
                    },
                    obscureText: true
                ),
                const SizedBox(height: 10),

                // Passwort bestätigen
                const SizedBox(height: 3),
                TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(labelText: "Passwort erneut eingeben"),
                    validator: (value) {
                      return (value!.trim() != passwordController.text.trim()) ? "Passwörter stimmen nicht überein" : null;
                    },
                    obscureText: true
                ),
                */
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!passwordResetFormKey.currentState!.validate()) {
                return;
              }
              /* TODO: löschen
              // Manuell in der App das Passwort zurücksetzen
              String newPassword = passwordController.text.trim();
              if (newPassword.isEmpty) {
                return;
              }*/

              try {
                // TODO: löschen
                // await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                String email = emailController.text.trim();
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                SnackBarService.showMessage("Passwort-Reset-Link gesendet!");
                //resetLinkSent = true;
                context.pop();
              } catch (e) {
                SnackBarService.showMessage("Fehler: ${e.toString()}");
              }
            },
            child: Text("Senden"),
          ),
        ],
      ),
    );

    /* TODO: löschen
    // Manuell in der App das Passwort zurücksetzen
    if (!resetLinkSent) {
      return;
    }

    // Password Reset Code Dialog:
    final passwordResetCodeFormKey = GlobalKey<FormState>();
    final codeController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Passwort zurücksetzen"),
          content: SingleChildScrollView(
            child: Form(
              key: passwordResetCodeFormKey,
              child: Column(
                children: [
                  FormHeaderText("Bitte geben Sie den Code aus der E-Mail ein:"),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: "Bestätigungscode"),
                  ),
                ],
              ),
            )
          ),
          actions: [
            TextButton(
              child: const Text("Abbrechen"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text("Bestätigen"),
              onPressed: () async {
                final code = codeController.text.trim();
                final newPassword = passwordController.text.trim();

                if (code.isEmpty) {
                  SnackBarService.showMessage("Bitte alle Felder ausfüllen.");
                  return;
                }

                try {
                  // Code überprüfen
                  final email = await FirebaseAuth.instance.verifyPasswordResetCode(code);

                  // Passwort endgültig zurücksetzen
                  await FirebaseAuth.instance.confirmPasswordReset(
                    code: code,
                    newPassword: newPassword,
                  );

                  // Bestätigungsmeldung
                  SnackBarService.showMessage("Passwort für $email erfolgreich zurückgesetzt.");
                  Navigator.of(ctx).pop(); // Dialog schließen
                } catch (e) {
                  SnackBarService.showMessage("Fehler: $e");
                }
              },
            ),
          ],
        );
      },
    );
    */
  }

  static Future<void> changePassword(BuildContext context) async {
    // User und userID holen:
    User? user = FirebaseAuth.instance.currentUser as User?; // Get current user
    if (user == null) {
      SnackBarService.showMessage("Kein Benutzer eingeloggt!");
      return;
    }

    String userId = user.uid;

    if (user.email == null) {
      SnackBarService.showMessage("Keine E-Mail gefunden!");
      return;
    }
    /*
    await user.reauthenticateWithCredential(userCredential);
    user.updatePassword(newPassword);*/
  }

  static Future<File?> changeProfilepicture() async {
    File? _imageFile;
    /* TODO: Image Picker kompatible Version finden
    final ImagePicker _picker = ImagePicker();


    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      return _imageFile;
    }*/
    return null;
  }

  /// Löscht den gerade eingeloggten Benutzer [AuthService.user] und meldet ihn mit [AuthService.logout] ab.
  /// Gibt zurück, ob der Benutzer erfolgreich gelöscht wurde, oder nicht.
  static Future<bool> deleteAccount() async {
    if (AuthService.instance.user == null) {
      return false;
    }
    int id = AuthService.instance.user!.id;

    if (AuthService.instance.user?.id == null) {
      return false;
    }

    var url = Uri.https(
      apiBaseUrl,
      '$auth/delete/$id',
    );
    try {
      http.Response response = await http.delete(url);
      // print('deleteAccount (Benutzer: ${AuthService.instance.user!.id}): ${response.statusCode} ${response.reasonPhrase}');

      if (response.statusCode == 404) {
        SnackBarService.showMessage('Benutzer nicht gefunden!');
        return false;
      }
      if (response.statusCode != 200) {
        SnackBarService.showMessage(
            'Account-Löschung fehlgeschlagen! (Status-Code: ${response.statusCode} ${response.reasonPhrase})');
        return false;
      }
      return AuthService.instance.logout();
    } catch (e) {
      SnackBarService.showMessage('Fehler: $e');
      return false;
    }
  }
}
