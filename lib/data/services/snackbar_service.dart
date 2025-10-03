import 'package:flutter/material.dart';

import '../../main.dart';

class SnackBarService {
  static void showMessage(String text,
      {Duration duration = const Duration(seconds: 4)}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: duration,
      ),
    );
  }
}
