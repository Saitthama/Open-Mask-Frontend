import 'package:flutter/material.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/widgets/filter_grid.dart';
import 'package:open_mask/ui/widgets/filter_icon.dart';

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
      required this.onTap,
      this.size = const Size(45, 45)});

  /// Der konkrete, darzustellende Filter.
  final Filter filter;

  /// Gibt an, ob das Element als ausgewählt markiert werden soll.
  final bool isSelected;

  /// Wird ausgeführt, wenn das [FilterTile] geklickt wird.
  final Function(Filter) onTap;

  /// Gibt die Größe des inneren Kreises an.
  final Size size;

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(filter),
      child: Column(
        children: [
          FilterIcon(filter: filter, isSelected: isSelected, size: size),
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
