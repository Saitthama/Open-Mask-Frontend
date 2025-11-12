import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// TODO: umstellen auf Java Backend
/// Repository zum Ausführen von Zugriffen auf das Backend für die Benutzerverwaltung
class AuthRepository {
  /// Meldet den Benutzer mit Email und Passwort an
  static Future<UserCredential> signIn(
      final String email, final String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Meldet den aktuellen Benutzer aus
  static Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  /// Erstellt einen Benutzer
  static Future<UserCredential> createUser(final String email,
      final String password, final username, final name) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await FirebaseFirestore.instance
        .collection('User')
        .doc(userCredential.user!.uid)
        .set({
      'name': name,
      'username': username,
      'email': email,
      'createdAt': Timestamp.now(),
    });
    return userCredential;
  }

  /// Sendet eine Verifizierungsemail
  static Future<void> sendEmailVerification(
      final UserCredential userCredential) async {
    return userCredential.user?.sendEmailVerification();
  }
}
