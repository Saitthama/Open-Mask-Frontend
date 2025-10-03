import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/ui/screens/register_screen.dart';
import 'package:open_mask/ui/view_models/login_view_model.dart';
import 'package:open_mask/ui/views/login_form_view.dart';
import 'package:provider/provider.dart';

import 'camera_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routePath = "/login";

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, vm, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!vm.isLoading && vm.isLoggedIn) {
              context.pushReplacement(CameraScreen.routePath);
            }
          });

          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bild oben
                  Container(
                    margin: const EdgeInsets.only(top: 0),
                    child: Image.asset(
                      'assets/images/app_logo_login_screen.jpeg',
                      // Pfad zum Logo
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
                  LoginFormView(),
                  const SizedBox(height: 20),
                  // Registrieren-Link
                  TextButton(
                      child: Text(
                        'Noch kein Konto? Jetzt registrieren',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        // Registrierungsseite öffnen
                        context.push(RegisterScreen.routePath);
                      }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
