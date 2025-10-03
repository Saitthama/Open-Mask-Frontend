import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetPopup {
  static Future<void> show(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Passwort zurücksetzen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Bitte gib deine E-Mail-Adresse ein, um dein Passwort zurückzusetzen."),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "E-Mail"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () async {
              String email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Passwort-Reset-Link gesendet!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Fehler: ${e.toString()}")),
                  );
                }
              }
            },
            child: Text("Senden"),
          ),
        ],
      ),
    );
  }
}
