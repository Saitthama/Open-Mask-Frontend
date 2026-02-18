import 'package:flutter/material.dart';

/// Roter Knopf mit Mistkübel-Icon und weißem Text. Wird in grau angezeigt, wenn er deaktiviert ist.
class DeleteTextButton extends StatelessWidget {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>Der [text] wird in der Mitte des Knopfes dargestellt.</li>
  ///   <li>Die Funktion [onPressed] wird aufgerufen, wenn der Knopf gedrückt wird. Wenn diese null ist, ist der Knopf deaktiviert.</li>
  ///   <li>Der Parameter [stretch] gibt an, ob der Knopf die maximale verfügbare Größe verwenden soll.</li>
  /// </ul>
  const DeleteTextButton(this.text,
      {super.key, required this.onPressed, this.stretch = false});

  /// Textinhalt, welcher in der Mitte des Knopfes dargestellt wird.
  final String text;

  /// Funktion, welche aufgerufen werden soll, wenn der Knopf gedrückt wird. Wenn diese null ist, ist der Knopf deaktiviert.
  final VoidCallback? onPressed;

  /// Gibt an, ob der Knopf die maximale verfügbare Größe verwenden soll.
  final bool stretch;

  @override
  Widget build(final BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Row(
        // Stretch
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
        spacing: 5.0,
        children: [
          Icon(Icons.delete_rounded,
              color: onPressed != null ? Colors.white : Colors.grey),
          Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: onPressed != null ? Colors.white : Colors.grey)),
        ],
      ),
    );
  }
}
