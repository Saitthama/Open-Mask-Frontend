import 'package:flutter/material.dart';

/// Ein Text mit einem Icon für die Bearbeitung des Textes.
class EditableTextTile extends StatefulWidget {
  /// Konstruktor.
  const EditableTextTile(
      {super.key, required this.getText, required this.setText});

  /// Getter für den Text, der angezeigt werden soll.
  final String Function() getText;

  /// Dient dazu, den originalen Text auf den veränderten Wert zu setzen.
  final void Function(String text)? setText;

  @override
  State<EditableTextTile> createState() => _EditableTextTileState();
}

/// [State] des [EditableTextTile].
class _EditableTextTileState extends State<EditableTextTile> {
  /// Gibt an, ob der Text gerade bearbeitet wird.
  bool isEditing = false;

  /// Controller für die Steuerung des Textes.
  late TextEditingController controller;

  /// Fokussteuerung für den Text.
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.getText());
  }

  /// Startet die Bearbeitung des Textes.
  void startEditing() {
    setState(() => isEditing = true);

    Future.delayed(const Duration(milliseconds: 50), () {
      focusNode.requestFocus();
    });
  }

  /// Beendet die Bearbeitung und speichert den Text.
  void finishEditing() {
    widget.setText?.call(controller.text);

    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(final BuildContext context) {
    controller.text = widget.getText();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        isEditing
            ? Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (final _) => finishEditing(),
                  onEditingComplete: finishEditing,
                ),
              )
            : Flexible(
                child: Text(
                  widget.getText(),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
        widget.setText != null
            ? IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit),
                onPressed: isEditing ? finishEditing : startEditing,
              )
            : const SizedBox(
                width: 40,
              ), // für bessere Zentrierung
      ],
    );
  }
}
