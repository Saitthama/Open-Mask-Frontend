import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Popup zum Auswählen einer Farbe.
class ColorPickerPopup extends StatefulWidget {
  /// Standard-Konstruktor.
  const ColorPickerPopup(
      {super.key, required this.getColor, required this.setColor});

  /// Getter für die initiale Farbe, die angezeigt werden soll.
  final Color Function() getColor;

  /// Dient dazu, die Farbe auf den veränderten Wert zu setzen.
  final void Function(Color color) setColor;

  @override
  State<ColorPickerPopup> createState() => _ColorPickerPopupState();
}

/// [State] des [ColorPickerPopup].
class _ColorPickerPopupState extends State<ColorPickerPopup> {
  /// Aktuelle ausgewählte Farbe.
  late Color pickerColor;

  @override
  void initState() {
    super.initState();
    pickerColor = widget.getColor();
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Farbauswahl'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: (final Color color) => setState(() {
            pickerColor = color;
          }),
        ),
        // Use Material color picker:
        //
        // child: MaterialPicker(
        //   pickerColor: pickerColor,
        //   onColorChanged: changeColor,
        //   showLabel: true, // only on portrait mode
        // ),
        //
        // Use Block color picker:
        //
        // child: BlockPicker(
        //   pickerColor: currentColor,
        //   onColorChanged: changeColor,
        // ),
        //
        // child: MultipleChoiceBlockPicker(
        //   pickerColors: currentColors,
        //   onColorsChanged: changeColors,
        // ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Bestätigen'),
          onPressed: () {
            setState(() => widget.setColor(pickerColor));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
