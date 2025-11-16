import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_mask/data/services/account_service.dart';
import 'package:open_mask/ui/widgets/logout_button.dart';
import 'package:open_mask/ui/widgets/navigation_bar.dart';

import '../../data/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  static const routePath = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // TODO: In User verschieben
  File? _profileImage;

  // TODO: in Service verschieben
  Future<void> _changeProfilePicture() async {
    final image = await AuthService.changeProfilepicture();
    if (image != null) {
      _profileImage = image;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : AssetImage('assets/images/default_avatar.png')
                                  as ImageProvider,
                        ),
                        SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: _changeProfilePicture,
                          icon: Icon(Icons.image),
                          label: Text("Change Profile Picture"),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingButton(
                          'Benutzername ändern',
                          () => AuthService.editUsername(context),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingButton(
                          'Email zurücksetzen',
                          () => AuthService.resetEmail(context),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingButton(
                          'Passwort zurücksetzen',
                          () => AuthService.resetPassword(context),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingButton(
                          'Account löschen',
                          () => AccountService.deleteAccount(context),
                        ),
                        const SizedBox(height: 25),
                        const LogoutButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomNavigationBar(currentRoute: SettingsScreen.routePath)
        ],
      ),
    );
  }

  Widget _buildSettingButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
