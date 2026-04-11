import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/data/services/storage_service.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/ui/screens/filter_editor_screen.dart';
import 'package:open_mask/ui/screens/filter_workshop_screen.dart';
import 'package:open_mask/ui/view_models/filter_workshop_view_model.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';
import 'package:open_mask/ui/widgets/filter_list.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

/// View, welches die UI für die Filterübersicht enthält und dem [FilterWorkshopScreen] bereitstellt.
/// Nutzt das [FilterEditorViewModel] für Logik.
class FilterWorkshopView extends StatefulWidget {
  /// Standard-Konstruktor.
  const FilterWorkshopView({super.key});

  @override
  State<FilterWorkshopView> createState() => _FilterWorkshopViewState();
}

/// [State] des [FilterWorkshopView].
class _FilterWorkshopViewState extends State<FilterWorkshopView> {
  @override
  Widget build(final BuildContext context) {
    FilterWorkshopViewModel vm = context.watch<FilterWorkshopViewModel>();

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
                    onPressed: () async {
                      List<IFilter> filters =
                          await StorageService.instance.importFilterList();
                      if (filters.isNotEmpty) {
                        await FilterStore.instance.importFilters(filters);
                      }
                    },
                  ),
                  BlueTextButton(
                    'Exportieren',
                    onPressed: vm.selected.isEmpty
                        ? null
                        : () async {
                            List<String> paths = await StorageService.instance
                                .exportFilterList(vm.selected);
                            if (paths.length == 1) {
                              SnackBarService.showMessage(
                                  'Filter als ${basename(paths.first)} exportiert');
                            } else if (paths.length > 1) {
                              final parts = paths.first
                                  .replaceAll('primary:', '')
                                  .split('/');
                              final dirName = parts[parts.length - 2];
                              SnackBarService.showMessage(
                                  '${paths.length} Filter in $dirName exportiert');
                            }
                            vm.clearSelection();
                          },
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
                    onDelete: vm.removeLocalFilter,
                    onFork: (final filter) {
                      FilterStore.instance.addLocalFilter(filter.fork());
                    },
                    changeNotifier: vm,
                    onSelected: vm.onSelected,
                    isSelected: vm.isSelected,
                  ),
                  FilterList(
                    getFilterList: () => FilterStore.instance.communityFilters,
                    onDelete: vm.removeCommunityFilter,
                    onFork: (final filter) {
                      FilterStore.instance.addLocalFilter(filter.fork());
                    },
                    changeNotifier: vm,
                    onSelected: vm.onSelected,
                    isSelected: vm.isSelected,
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
