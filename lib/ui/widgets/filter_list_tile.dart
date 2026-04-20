import 'package:flutter/material.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/widgets/filter_icon.dart';

import 'filter_meta_popup.dart';

/// Listenelement, welches einen Filter aus einer Liste für die Bearbeitung repräsentiert.
class FilterListTile extends StatelessWidget {
  /// Konstruktor, welcher den darzustellenden [filter] bekommt.
  const FilterListTile(
      {super.key,
      required this.filter,
      required this.onEdit,
      required this.onDelete,
      required this.onFork,
      required this.onSelected,
      required this.isSelected});

  /// Der darzustellende Filter.
  final Filter filter;

  /// Wird beim Drücken des Bearbeitungs-Buttons aufgerufen.
  final VoidCallback? onEdit;

  /// Wird beim Drücken des Delete-Buttons aufgerufen.
  final VoidCallback? onDelete;

  /// Wird beim Drücken des Fork-Buttons aufgerufen.
  final VoidCallback? onFork;

  /// Wird aufgerufen, wenn das Element in einem Bereich angeklickt wird,
  /// der nicht bereits durch eine andere Aktion belegt ist, und dient zum Auswählen des Filters.
  final Function(Filter filter)? onSelected;

  /// Gibt an, ob der Filter ausgewählt ist.
  final bool isSelected;

  @override
  Widget build(final BuildContext context) {
    final Color? onBackground = isSelected ? Colors.white : null;
    return Container(
      decoration: BoxDecoration(color: isSelected ? Colors.blue : null),
      child: ListTile(
        leading: FilterIcon(
          filter: filter,
          isSelected: false,
          size: const Size(30, 30),
          isEditable: onEdit != null,
        ),
        title: Text(
          filter.meta.name,
          style: TextStyle(color: onBackground),
        ),
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
                    icon: Icon(
                      Icons.fork_right_rounded,
                      color: onBackground,
                    )),
              if (onEdit != null)
                IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_rounded,
                      color: onBackground,
                    )),
              if (onEdit == null)
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withAlpha(180),
                        builder: (final context) => FilterMetaPopup(filter),
                      );
                    },
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: onBackground,
                    ))
            ],
          ),
        ),
        onTap: () => onSelected?.call(filter),
      ),
    );
  }
}
