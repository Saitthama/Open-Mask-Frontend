import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/pages/register_page.dart';
import 'package:open_mask/services/account_service.dart';
import 'package:open_mask/services/snackbar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/stretched_button.dart';
import 'camera_page.dart';

class LoginPage extends StatefulWidget {
  static const routePath = "/login";

  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _saveLogin = false;

  // Gespeicherte Login daten werden geladen
  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _saveLogin = prefs.getBool('saveLogin') ?? false;
      if (_saveLogin) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Überprüfung, ob E-Mail und Passwort ausgefüllt ist
      if (email.isEmpty || password.isEmpty) {
        SnackBarService.showMessage('Bitte E-Mail und Passwort angeben!');
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //region [Wenn das Hackerl bei angemeldet bleiben true ist, werden die Daten gespeichert]
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        await prefs.setBool('rememberMe', true);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
      //endregion

      // Überprüfen, ob die E-Mail schon verifiziert wurde
      if (userCredential.user!.emailVerified == false) {
        // Verifizierungs-E-Mail erneut senden
        await userCredential.user!.sendEmailVerification();

        await FirebaseAuth.instance.signOut();

        SnackBarService.showMessage(
            'E-Mail wurde noch nicht verifiziert! \nBitte überprüfen Sie ihren Posteingang!');
        return;
      }

      SnackBarService.showMessage('Login erfolgreich!');

      // Home Screen öffnen
      context.pushReplacement(CameraPage.routePath);
    } catch (e) {
      SnackBarService.showMessage('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bild oben
            Container(
              margin: const EdgeInsets.only(top: 0),
              child: Image.asset(
                'assets/images/app_logo_login_screen.jpeg', // Pfad zum Logo
                width: MediaQuery.of(context).size.width,
              ),
            ),
            const SizedBox(height: 20),
            // Willkommen-Text
            const Text(
              'Willkommen!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Eingabefelder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email-Adresse
                    const SizedBox(height: 3),
                    TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(hintText: 'E-Mail-Adresse'),
                        validator: (value) {
                          return (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@'))
                              ? 'Bitte gültige E-Mail eingeben'
                              : null;
                        }),
                    const SizedBox(height: 20),
                    // Passwort
                    TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(hintText: 'Passwort'),
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Bitte Passwort eingeben'
                              : null;
                        },
                        obscureText: true),
                    const SizedBox(height: 10),
                    // Passwort vergessen
                    GestureDetector(
                      onTap: () {
                        AccountService.resetPassword(context);
                      },
                      child: const Text(
                        'Passwort vergessen?',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                        Text('Angemeldet bleiben'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Login-Button
            StretchedButton('Login', _login, 0.9),
            const SizedBox(height: 20),
            // Registrieren-Link
            TextButton(
                child: Text(
                  'Noch kein Konto? Jetzt registrieren',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  // Registrierungsseite öffnen
                  context.push(RegisterPage.routePath);
                }),
            const SizedBox(height: 30),
            // Social Media Buttons (ohne Funktionalität)
            /* TODO: Anbieter einrichten und Logik implementieren
            const Divider(
              color: Colors.grey,
              indent: 30,
              endIndent: 30,
            ),
            const SizedBox(height: 10),
            const Text(
              'Oder fortfahren mit',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.g_mobiledata_rounded, Colors.red),
                const SizedBox(width: 20),
                _buildSocialButton(Icons.apple, Colors.white70),
                const SizedBox(width: 20),
                _buildSocialButton(Icons.facebook, Colors.blue),
              ],
            ),*/
          ],
        ),
      ),
    );
  }

  // TODO: fertig einrichten und Anbieter auswählen
  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: () {
          // Social Media Login Logik
        },
      ),
    );
  }
}

// TODO: in eigenem File andere Seiten erstellen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Willkommen!')),
    );
  }
}
