import 'package:flutter/material.dart';

class FormHeaderText extends StatelessWidget {
  final String _text;

  const FormHeaderText(this._text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

