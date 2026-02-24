import 'package:flutter/material.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/widgets/filter_tile.dart';

/// Enum, welches die verschiedenen Tabs der Filterauswahl beinhaltet.
enum FilterTab { general, own, community }

/// Widget, welches die Filter des angegebenen Tabs als [GridView] darstellt.
class FilterGrid extends StatelessWidget {
  /// Standard-Konstruktor. [type] gibt den ausgewählten Tab an.
  const FilterGrid({super.key, required this.type});

  /// Der Typ des aktuell ausgewählten Tabs.
  final FilterTab type;

  @override
  Widget build(final BuildContext context) {
    final store = FilterStore.instance;

    final filters = switch (type) {
      FilterTab.general => [
          ...store.localFilters.where((final IFilter filter) =>
              (filter as Filter).meta.createdBy ==
              null), // vordefinierte Filter
        ],
      FilterTab.own => [
          ...store.localFilters.where((final IFilter filter) =>
              (filter as Filter).meta.createdBy != null),
          // Filter, die selbst erstellt (oder lokal importiert) wurden
        ],
      FilterTab.community => store.communityFilters,
    };

    if (filters.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Noch keine Elemente vorhanden',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    /// Speichert den angegebenen Filter als ausgewählten Filter für die Verwendung.
    void onTap(final Filter element) {
      FilterStore.instance.selectedFilter = element;
      Navigator.pop(context);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: filters.length,
      itemBuilder: (final _, final index) {
        final filter = filters[index];
        final isSelected = store.selectedFilter == filter;
        return FilterTile(
          filter: filter as Filter,
          isSelected: isSelected,
          onTap: onTap,
        );
      },
    );
  }
}
