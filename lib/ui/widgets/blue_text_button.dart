import 'package:flutter/material.dart';

/// Blauer [ElevatedButton].
class BlueTextButton extends StatelessWidget {
  /// Standard-Konstruktor.
  const BlueTextButton(this.text,
      {super.key,
      this.onPressed,
      this.padding =
          const EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 10),
      this.leadingIcon,
      this.stretch = false});

  /// Textinhalt, welcher in der Mitte des Knopfes dargestellt wird.
  final String text;

  /// Funktion, welche aufgerufen werden soll, wenn der Knopf gedrückt wird. Wenn diese null ist, ist der Knopf deaktiviert.
  final void Function()? onPressed;

  /// Das Padding, welches der Button haben soll.
  final EdgeInsetsGeometry padding;

  /// Icon, welches vor dem Text dargestellt wird, falls es gesetzt wird.
  final IconData? leadingIcon;

  /// Gibt an, ob der Knopf die maximale verfügbare Größe verwenden soll.
  final bool stretch;

  @override
  Widget build(final BuildContext context) {
    final Text textWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
      ),
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: padding,
        iconColor: Colors.white,
        foregroundColor: Colors.white,
        overlayColor: Colors.white.withAlpha(200),
        disabledForegroundColor: Colors.grey,
        disabledIconColor: Colors.grey,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
        spacing: 5.0,
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
            )
          ],
          textWidget,
        ],
      ),
    );
  }
}
