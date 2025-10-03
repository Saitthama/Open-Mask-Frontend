import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailResetPopup {
  static Future<void> show(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser; // Get current user

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("E-Mail-Adresse ändern"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Gib deine neue E-Mail-Adresse ein."),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Neue E-Mail"),
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
              String newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty && user != null) {
                try {
                  await user.verifyBeforeUpdateEmail(newEmail);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Bestätigungs-E-Mail gesendet!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Fehler: ${e.toString()}")),
                  );
                }
              }
            },
            child: Text("E-Mail ändern"),
          ),
        ],
      ),
    );


  }
}
