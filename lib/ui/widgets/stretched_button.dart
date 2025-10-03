import 'package:flutter/material.dart';

class StretchedButton extends StatelessWidget {
  final String _text;
  final void Function()? _onPressed;
  final double _widthPercent;

  const StretchedButton(this._text, this._onPressed, this._widthPercent, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * _widthPercent,
      child: ElevatedButton(
        onPressed: _onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          _text,
          style: TextStyle(
              fontSize: 16,
              color: Colors.white
          ),
        ),
      ),
    );
  }
}