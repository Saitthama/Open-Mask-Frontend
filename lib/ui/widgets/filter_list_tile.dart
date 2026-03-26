import 'package:flutter/material.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/widgets/filter_icon.dart';

/// Listenelement, welches einen Filter aus einer Liste für die Bearbeitung repräsentiert.
class FilterListTile extends StatelessWidget {
  /// Konstruktor, welcher den darzustellenden [filter] bekommt.
  const FilterListTile(
      {super.key,
      required this.filter,
      required this.onEdit,
      required this.onDelete,
      required this.onFork});

  /// Der darzustellende Filter.
  final Filter filter;

  /// Wird beim Drücken des Bearbeitungs-Buttons aufgerufen.
  final VoidCallback? onEdit;

  /// Wird beim Drücken des Delete-Buttons aufgerufen.
  final VoidCallback? onDelete;

  /// Wird beim Drücken des Fork-Buttons aufgerufen.
  final VoidCallback? onFork;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      leading: FilterIcon(
          filter: filter, isSelected: false, size: const Size(30, 30)),
      title: Text(filter.meta.name),
      trailing: FittedBox(
        child: Row(
          children: [
            if (onDelete != null)
              IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                  )),
            if (onFork != null)
              IconButton(
                  onPressed: onFork,
                  icon: const Icon(Icons.fork_right_rounded)),
            if (onEdit != null)
              IconButton(
                  onPressed: onEdit, icon: const Icon(Icons.edit_rounded)),
          ],
        ),
      ),
    );
  }
}
