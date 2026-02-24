import 'package:flutter/material.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/widgets/filter_tile.dart';

/// Widget, welches die Filter des angegebenen [FilterType] sowie Optionen zum Erstellen neuer Filter als [GridView] darstellt.
class AddFilterGrid extends StatelessWidget {
  /// Standard-Konstruktor. Der [FilterType] gibt die Art der Filter an, welche angezeigt werden sollen.
  const AddFilterGrid({super.key, required this.filterType});

  /// Gibt die Art der Filter an, welche angezeigt werden sollen.
  final FilterType filterType;

  @override
  Widget build(final BuildContext context) {
    final FilterStore store = FilterStore.instance;

    bool searchFunction(final IFilter filter) =>
        (filter as Filter).type == filterType;
    final List<IFilter> filters =
        List.from(store.localFilters.where(searchFunction));

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

    void onTap(final Filter element) {
      element.meta.icon = null;
      FilterStore.instance.addFilterToEdit(element);
      Navigator.pop(context);
    }

    final itemCount = filters.length + 1;
    return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: itemCount,
        itemBuilder: (final _, final index) {
          if (index == 0) {
            final Filter newFilter =
                FilterFactory.create(filterType, isCreatedByUser: true)
                    as Filter;
            newFilter.meta.icon = Icon(
              Icons.add_rounded,
              color: (ButtonTheme.of(context).colorScheme == null)
                  ? Colors.black
                  : ButtonTheme.of(context).colorScheme!.onPrimary,
            );

            return FilterTile(
              filter: newFilter,
              onTap: onTap,
              isSelected: false,
            );
          }

          final int i = index - 1;
          final filter = filters[i] as Filter;
          return FilterTile(
            filter: filter,
            onTap: onTap,
            isSelected: false,
          );
        });
  }
}
