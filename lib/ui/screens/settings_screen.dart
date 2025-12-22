import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_mask/data/services/account_service.dart';
import 'package:open_mask/ui/widgets/logout_button.dart';

import '../widgets/delete_user_popup.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const routePath = '/settings';

  /// Gibt den Index des Settings-Tabs für das Shell-Routing an.
  static const int settingsBranchIndex = 2;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // TODO: In User verschieben
  File? _profileImage;

  // TODO: in Service verschieben
  Future<void> _changeProfilePicture() async {
    final image = await AccountService.changeProfilepicture();
    if (image != null) {
      _profileImage = image;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, title: const Text('Settings')),
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
                              : const AssetImage(
                                      'assets/images/default_avatar.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: _changeProfilePicture,
                          icon: const Icon(Icons.image),
                          label: const Text('Change Profile Picture'),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingButton(
                          'Benutzername ändern',
                          () => AccountService.editUsername(context),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingButton(
                          'Email zurücksetzen',
                          () => AccountService.resetEmail(context),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingButton(
                          'Passwort zurücksetzen',
                          () => AccountService.resetPassword(context),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingButton('Passwort ändern',
                            () => AccountService.changePassword(context)),
                        const SizedBox(height: 15),
                        _buildSettingButton(
                          'Account löschen',
                          () => DeleteUserPopup.openPopup(context),
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
