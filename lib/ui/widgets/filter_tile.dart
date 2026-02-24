import 'package:flutter/material.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/widgets/filter_grid.dart';

/// Einzelnes Filterelement, welches im [FilterGrid] benutzt wird
/// und beim Auswählen [onTap] mit dem [filter] aufruft.
class FilterTile extends StatelessWidget {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>[filter] ist der konkrete, darzustellende Filter.</li>
  ///   <li>Wenn [isSelected] true ist, wird das Element als ausgewählt markiert.</li>
  ///   <li>Beim anklicken des Elements wird [onTap] aufgerufen.</li>
  /// </ul>
  const FilterTile(
      {super.key,
      required this.filter,
      required this.isSelected,
      required this.onTap});

  /// Der konkrete, darzustellende Filter.
  final Filter filter;

  /// Gibt an, ob das Element als ausgewählt markiert werden soll.
  final bool isSelected;

  /// Wird ausgeführt, wenn das [FilterTile] geklickt wird.
  final Function(Filter) onTap;

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(filter),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(220),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: 45,
              height: 45,
              child: FittedBox(
                child: filter.meta.icon,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            filter.meta.name,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
