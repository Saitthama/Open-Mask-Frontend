import 'package:flutter/material.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/ui/widgets/add_filter_grid.dart';

/// Popup für die Auswahl eines Filters, um diesen im Editor hinzuzufügen.
class AddFilterPopup extends StatelessWidget {
  /// Standard-Konstruktor.
  const AddFilterPopup({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final grids = [];
    final tabs = [];
    for (final FilterType type in FilterType.values) {
      grids.add(AddFilterGrid(filterType: type));
      tabs.add(Tab(
        text: filterTypeNames[type] ??
            '${type.name[0].toUpperCase()}${type.name.substring(1)}',
      ));
    }

    return Dialog(
      backgroundColor: theme.colorScheme.surface.withAlpha(220),
      insetPadding: const EdgeInsets.all(15),
      child: DefaultTabController(
        length: tabs.length,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
              border: BoxBorder.all(
                  color: theme.colorScheme.onSurface.withAlpha(220)),
              borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  tabs: [...tabs],
                ),
                Expanded(
                  child: TabBarView(
                    children: [...grids],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
