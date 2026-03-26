import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/routing/active_branch_notifier.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/widgets/filter_selection_popup.dart';

/// Listenelement zum Ein- und Aussschalten des Filters, sowie zum Aufrufen der Filterauswahl.
/// Setzt den Kamera-Branch zurück, wenn erfolgreich ein neuer Filter ausgewählt wurde.
class FilterOptionListTile extends StatefulWidget {
  /// Standard-Konstruktor.
  const FilterOptionListTile({super.key, required this.viewModel});

  /// Dient zum Ein- und Ausschalten des Filters, zum Abrufen des Zustands sowie zum Aufrufen der Filterauswahl.
  final CameraViewModel viewModel;

  @override
  State<FilterOptionListTile> createState() => _FilterOptionListTileState();
}

/// [State] des [FilterOptionListTile].
class _FilterOptionListTileState extends State<FilterOptionListTile> {
  /// Dient dazu, [setState] bei Änderungen des Zustands aufzurufen.
  late void Function() listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
    widget.viewModel.addListener(listener);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      selected: widget.viewModel.filterActive,
      leading: const Icon(
        Icons.photo_filter,
      ),
      title: widget.viewModel.filterActive
          ? const Text('Filter auswählen')
          : const Text('Filter aktivieren'),
      onTap: () async {
        if (!widget.viewModel.filterActive) {
          widget.viewModel.switchFilterActive();
          return;
        }
        IFilter? lastFilter = FilterStore.instance.selectedFilter;
        await showDialog(
            context: context,
            barrierColor: Theme.of(context).colorScheme.surface.withAlpha(180),
            builder: (final context) {
              return const FilterSelectionPopup();
            });
        // Branch zurücksetzen, um wieder auf die Hauptkameraseite zu gelangen, wenn erfolgreich ein anderer Filter ausgewählt wird.
        if (context.mounted &&
            FilterStore.instance.selectedFilter != lastFilter) {
          ActiveBranchNotifier.instance.value = -1;
          ActiveBranchNotifier.instance.value = CameraScreen.cameraBranchIndex;
          context.go(CameraScreen.routePath);
        }
      },
      onLongPress: () => widget.viewModel.switchFilterActive(),
    );
  }
}
