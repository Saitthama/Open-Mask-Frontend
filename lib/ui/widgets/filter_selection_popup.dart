import 'package:flutter/material.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/filter_tab.dart';
import 'package:open_mask/ui/widgets/filter_grid.dart';

/// Popup für die Auswahl eines Filters, um diesen zu verwenden. Der akutelle Filter wird im [FilterStore] gespeichert.
class FilterSelectionPopup extends StatelessWidget {
  /// Standard-Konstruktor.
  const FilterSelectionPopup({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface.withAlpha(220),
      insetPadding: const EdgeInsets.all(15),
      child: DefaultTabController(
        length: 3,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
              border: BoxBorder.all(
                  color: theme.colorScheme.onSurface.withAlpha(220)),
              borderRadius: BorderRadius.circular(25)),
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Allgemein'),
                    Tab(text: 'Eigene'),
                    Tab(text: 'Community'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      FilterGrid(type: FilterTab.general),
                      FilterGrid(type: FilterTab.own),
                      FilterGrid(type: FilterTab.community),
                    ],
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
