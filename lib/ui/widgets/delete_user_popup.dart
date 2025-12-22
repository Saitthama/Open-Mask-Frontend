import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

import '../../data/services/account_service.dart';
import '../screens/login_screen.dart';

/// Ein Pop-Up-Fenster zum Löschen des aktuellen Benutzers.
/// Meldet den Benutzer bei erfolgreichem Löschen ab und navigiert zurück zum [LoginScreen].
class DeleteUserPopup extends StatelessWidget {
  /// Standard-Konstruktor.
  const DeleteUserPopup({super.key});

  /// Öffnet das ein [DeleteUserPopup] im aktuellen [context].
  static Future<void> openPopup(final BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (final ctx) => const DeleteUserPopup(),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Account löschen bestätigen'),
      content: const Text(
          'Sind Sie sich sicher, dass Sie ihr Konto löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.'),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
            /// Löscht den User und loggt ihn aus.
            final successful = await AccountService.deleteAccount();

            /// Geht zurück zur Login Page, wenn die Löschung erfolgreich war.
            if (successful) {
              SnackBarService.showMessage('Account erfolgreich gelöscht!');
              if (context.mounted) context.go(LoginScreen.routePath);
            }
          },
          child: const Text('Löschen', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
