import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/ui/screens/filter_editor_screen.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';
import 'package:open_mask/ui/widgets/filter_list.dart';

/// Startseite der Filterwerkstatt.
class FilterWorkshopScreen extends StatefulWidget {
  /// Konstruktor.
  const FilterWorkshopScreen({super.key});

  /// Route zu der Seite, über die diese erreicht werden kann.
  static const routePath = '/filter-workshop';

  /// Gibt den Index des Filter-Workshop-Tabs für das Shell-Routing an.
  static const int filterWorkshopBranchIndex = 0;

  @override
  State<FilterWorkshopScreen> createState() => _FilterWorkshopScreenState();
}

/// [State] des [FilterWorkshopScreen].
class _FilterWorkshopScreenState extends State<FilterWorkshopScreen> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Filterwerkstatt'),
      ),
      body: DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Column(
          children: [
            // Button Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BlueTextButton(
                    'Importieren',
                    onPressed: () {},
                  ),
                  BlueTextButton(
                    'Exportieren',
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const TabBar(
              tabs: [
                Tab(text: 'Vordefiniert'),
                Tab(text: 'Eigene'),
                Tab(text: 'Community'),
              ],
            ),

            // Übersicht der eigenen lokalen Filter
            Expanded(
              child: TabBarView(
                children: [
                  FilterList(
                    getFilterList: FilterStore.instance.getPredefinedFilters,
                    onEdit: null,
                    onDelete: null,
                    onFork: (final filter) {
                      FilterStore.instance.addLocalFilter(filter.fork());
                    },
                    changeNotifier: null,
                  ),
                  FilterList(
                    getFilterList: FilterStore.instance.getOwnFilters,
                    onEdit: (final filter) {
                      FilterStore.instance.currentlyEditedFilter = filter;
                      _openEditor(context);
                    },
                    onDelete: FilterStore.instance.removeLocalFilter,
                    onFork: (final filter) {
                      FilterStore.instance.addLocalFilter(filter.fork());
                    },
                    changeNotifier: FilterStore.instance,
                  ),
                  FilterList(
                    getFilterList: () => FilterStore.instance.communityFilters,
                    onDelete: null,
                    onFork: (final filter) {
                      FilterStore.instance.addLocalFilter(filter.fork());
                    },
                    changeNotifier: FilterStore.instance,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () {
          FilterStore.instance.currentlyEditedFilter = null;
          _openEditor(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsetsGeometry.all(5),
          iconColor: Colors.white,
          foregroundColor: Colors.white,
          overlayColor: Colors.white.withAlpha(200),
        ),
        icon: const Icon(size: 50, Icons.add_rounded),
      ),
    );
  }

  /// Öffnet den [FilterEditorScreen] für die Filtererstellung.
  void _openEditor(final BuildContext context) {
    context.push(
        '${FilterWorkshopScreen.routePath}${FilterEditorScreen.routePath}');
  }
}
