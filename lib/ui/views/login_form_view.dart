import 'package:flutter/material.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/ui/view_models/login_view_model.dart';
import 'package:open_mask/ui/widgets/stretched_button.dart';
import 'package:provider/provider.dart';

class LoginFromView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  GlobalKey<FormState> get formKey => _formKey;

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  LoginFromView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    return Padding(
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
                AuthService.resetPassword(context);
              },
              child: const Text(
                'Passwort vergessen?',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Login-Button
            StretchedButton('Login', () {
              if (_formKey.currentState!.validate()) {
                vm.login(_emailController.text, _passwordController.text);
              }
            }, 0.9),
          ],
        ),
      ),
    );
  }
}
