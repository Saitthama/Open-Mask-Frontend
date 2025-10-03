import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

import '../screens/login_screen.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Möchtest du dich wirklich ausloggen?"),
          actions: [
            TextButton(
              onPressed: () => context.pop(), // Dialog schließen
              child: Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () {
                _logout(context);
                context.pop(); // Dialog schließen
              },
              child: Text("Ja, ausloggen"),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SnackBarService.showMessage("Erfolgreich ausgeloggt");

    // Zum Login-Screen navigieren
    context.pushReplacement(LoginScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showLogoutDialog(context),
      child: Text("Logout"),
    );
  }
}
