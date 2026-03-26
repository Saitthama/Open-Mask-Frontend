import 'package:flutter/material.dart';
import 'package:open_mask/filter/templates/filter.dart';

/// Stellt ein FilterIcon mit Hintergrund dar.
class FilterIcon extends StatelessWidget {
  /// Konstruktor, welcher den Filter bekommt, dessen Icon dargestellt werden soll.
  const FilterIcon(
      {super.key,
      required this.filter,
      required this.isSelected,
      required this.size});

  /// Filter, dessen Icon dargestellt werden soll.
  final Filter filter;

  /// Gibt an, ob der Filter ausgewählt ist und das Icon daher markiert werden soll.
  final bool isSelected;

  /// Gibt die Größe an, in der das Icon dargestellt werden soll.
  final Size size;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return FittedBox(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.surface)
              .withAlpha(220),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : isDarkMode
                    ? Colors.transparent
                    : theme.colorScheme.onSurface,
            width: 3,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: FittedBox(
            child: filter.meta.icon,
          ),
        ),
      ),
    );
  }
}
