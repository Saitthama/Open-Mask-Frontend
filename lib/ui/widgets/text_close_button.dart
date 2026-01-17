import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'blue_text_button.dart';

/// [BlueTextButton], welcher die aktuelle Seite schließt.
class TextCloseButton extends StatelessWidget {
  /// Standard-Konstruktor.
  const TextCloseButton({super.key, this.stretch = false});

  /// Gibt an, ob der Knopf die maximale verfügbare Größe verwenden soll.
  final bool stretch;

  @override
  Widget build(final BuildContext context) {
    return BlueTextButton('Schließen',
        onPressed: () => context.pop(), stretch: stretch);
  }
}
