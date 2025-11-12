import 'package:flutter/cupertino.dart';
import 'package:open_mask/data/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isRegistered = false;

  bool get isRegistered => _isRegistered;

  Future<void> register(final String email, final String password,
      final String username, final String name) async {
    _isRegistered = await AuthService.register(email, password, username, name);

    notifyListeners();
  }
}
