import 'package:flutter/material.dart';

/// Text mit einer Checkbox.
class TextWithCheckbox extends StatefulWidget {
  /// Standard-Konstruktor.
  const TextWithCheckbox(
      {super.key,
      required this.checkedText,
      required this.uncheckedText,
      required this.getValue,
      required this.setValue});

  /// Text, welcher angezeigt werden soll, wenn die Checkbox ausgewählt ist.
  final String checkedText;

  /// Text, welcher angezeigt werden soll, wenn die Checkbox nicht ausgewählt ist.
  final String uncheckedText;

  /// Getter für den Wert der Checkbox, der angezeigt werden soll.
  final bool Function() getValue;

  /// Dient dazu, den originalen Wert auf den veränderten Wert zu setzen.
  final void Function(bool value)? setValue;

  @override
  State<TextWithCheckbox> createState() => _TextWithCheckboxState();
}

class _TextWithCheckboxState extends State<TextWithCheckbox> {
  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.getValue() ? widget.checkedText : widget.uncheckedText),
        if (widget.setValue != null)
          Checkbox.adaptive(
              value: widget.getValue(),
              onChanged: (final value) {
                if (value == null) return;
                widget.setValue?.call(value);
                setState(() {});
              }),
      ],
    );
  }
}
