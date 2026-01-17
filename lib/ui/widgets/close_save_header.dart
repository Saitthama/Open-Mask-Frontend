import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ein Widget, welches aus einer [Row] mit einem [IconButton] zum Schließen der Seite, einer Überschrift und einem [IconButton] zum Speichern besteht.
class CloseSaveHeader extends StatelessWidget {
  /// Standard-Konstruktor.
  const CloseSaveHeader(
      {super.key,
      required this.header,
      required this.onSave,
      required this.saveActive});

  /// Die Überschrift, die als Text in der Mitte angezeigt werden soll.
  final String header;

  /// Ob Speichern aktiv sein soll.
  final bool saveActive;

  /// Callback für das Speichern. Kann nicht aufgerufen werden, falls [saveActive] false ist.
  final VoidCallback onSave;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          IconButton(
              padding: const EdgeInsets.all(0),
              iconSize: 40,
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close_rounded)),
          Expanded(child: Container()),
          // Titel
          Text(
            header,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Container()),
          IconButton(
              padding: const EdgeInsets.all(4),
              iconSize: 50,
              onPressed: saveActive ? onSave : null,
              disabledColor: theme.iconTheme.color?.withAlpha(100),
              icon: const Icon(Icons.save_rounded))
        ],
      ),
    );
  }
}
