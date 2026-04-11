import 'package:flutter/cupertino.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/screens/filter_workshop_screen.dart';
import 'package:open_mask/ui/views/filter_workshop_view.dart';

/// View-Model, welches die Logik für den [FilterWorkshopScreen] und das [FilterWorkshopView] hält.
class FilterWorkshopViewModel extends ChangeNotifier {
  /// Standard-Konstruktor.
  FilterWorkshopViewModel() {
    FilterStore.instance.addListener(notifyListeners);
  }

  /// Liste der aktuell ausgewählten Filter.
  final List<Filter> _selected = [];

  /// Readonly-Liste der aktuell ausgewählten Filter.
  List<Filter> get selected => List.unmodifiable(_selected);

  /// Wählt [filter] aus oder ab.
  void onSelected(final Filter filter) {
    if (!isSelected(filter)) {
      _selected.add(filter);
    } else {
      _selected.remove(filter);
    }
    notifyListeners();
  }

  /// Gibt an, ob der [filter] ausgewählt ist.
  bool isSelected(final Filter filter) {
    return _selected.contains(filter);
  }

  /// Löscht den [filter] aus den lokalen Filtern im [FilterStore] und aus [selected].
  Future<void> removeLocalFilter(final IFilter filter) async {
    bool success = await FilterStore.instance.removeLocalFilter(filter);
    if (success) {
      _selected.remove(filter);
    }
  }

  /// Löscht den [filter] aus den Community-Filtern im [FilterStore] und aus [selected].
  Future<void> removeCommunityFilter(final IFilter filter) async {
    bool success = await FilterStore.instance.removeCommunityFilter(filter);
    if (success) {
      _selected.remove(filter);
    }
  }

  /// Löscht alle Elemente aus [selected].
  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }
}
