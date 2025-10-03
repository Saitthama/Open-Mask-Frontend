import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/auth_service.dart';

import '../../data/services/snackbar_service.dart';
import '../widgets/form_header_text.dart';
import '../widgets/stretched_button.dart';

class RegisterScreen extends StatefulWidget {
  static const routePath = "/register";

  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller für die Eingabefelder
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isTermsAccepted = false;
  bool _isLoading = false;

  void _registerUser() async {
    if (!_formKey.currentState!.validate() || !_isTermsAccepted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    if (!await _isUsernameAvailable(username)) {
      SnackBarService.showMessage('Benutzername vergeben!');
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();

    bool authSuccessful =
        await AuthService.register(email, password, username, name);
    if (authSuccessful) {
      context.pop();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _isUsernameAvailable(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('User')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrieren')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    FormHeaderText('Name'),
                    const SizedBox(height: 3),
                    TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Name'),
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Bitte Name eingeben'
                              : null;
                        }),
                    const SizedBox(height: 10),
                    // Benutzername
                    FormHeaderText('Benutzername'),
                    SizedBox(height: 3),
                    TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(hintText: 'Benutzername'),
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Bitte Benutzernamen eingeben'
                              : null;
                        }),
                    const SizedBox(height: 10),
                    // Email-Adresse
                    FormHeaderText('Email-Adresse'),
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
                    const SizedBox(height: 10),
                    // Passwort
                    FormHeaderText('Passwort'),
                    SizedBox(height: 3),
                    TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(hintText: 'Passwort'),
                        validator: (value) {
                          return (value == null || value.length < 6)
                              ? 'Passwort muss mindestens 6 Zeichen haben'
                              : null;
                        },
                        obscureText: true),
                    const SizedBox(height: 10),
                    // Passwort bestätigen
                    FormHeaderText('Passwort bestätigen'),
                    const SizedBox(height: 3),
                    TextFormField(
                        controller: _confirmPasswordController,
                        decoration:
                            InputDecoration(hintText: 'Passwort bestätigen'),
                        validator: (value) {
                          return (value!.trim() !=
                                  _passwordController.text.trim())
                              ? 'Passwörter stimmen nicht überein'
                              : null;
                        },
                        obscureText: true),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _isTermsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _isTermsAccepted = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Ich habe die Nutzungsbedingungen und die Datenschutzrichtlinie gelesen.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : StretchedButton('Registrieren', _registerUser, 0.9),
          ],
        ),
      ),
    );
  }
}
