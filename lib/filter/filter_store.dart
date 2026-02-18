import 'package:flutter/cupertino.dart';
import 'package:open_mask/filter/i_filter.dart';

/// Datenhalter-Klasse, welche globale Filterdaten speichert.
class FilterStore extends ChangeNotifier {
  /// Privater Konstruktor für das Singleton-Pattern.
  FilterStore._internal();

  /// Singleton-Instanz.
  static final FilterStore instance = FilterStore._internal();

  /// Der aktuell ausgewählte Filter.
  IFilter? _selectedFilter;

  /// Der Filter, der aktuell im Filter-Editor bearbeitet wird.
  IFilter? _selectedEditorFilter;

  /// Alle lokalen Filter.
  final List<IFilter> _localFilters = [];

  /// Alle geladenen Community-Filter.
  final List<IFilter> _communityFilters = [];

  /// Der aktuell ausgewählte Filter.
  IFilter? get selectedFilter => _selectedFilter;

  /// Der Filter, der aktuell im Filter-Editor bearbeitet wird.
  IFilter? get selectedEditorFilter => _selectedEditorFilter;

  /// Alle lokalen Filter.
  List<IFilter> get localFilters => List.unmodifiable(_localFilters);

  /// Alle geladenen Community-Filter.
  List<IFilter> get communityFilters => List.unmodifiable(_communityFilters);

  set selectedFilter(final IFilter? newSelectedFilter) {
    if (newSelectedFilter != _selectedFilter) {
      newSelectedFilter?.load(); // neuen Filter asynchron laden
    }
    _selectedFilter = newSelectedFilter;
    notifyListeners();
  }

  set selectedEditorFilter(final IFilter? newSelectedEditorFilter) {
    if (newSelectedEditorFilter != _selectedEditorFilter) {
      newSelectedEditorFilter
          ?.load(); // Filter für die Bearbeitung asynchron laden
    }
    _selectedEditorFilter = newSelectedEditorFilter;
    notifyListeners();
  }

  /// Fügt den angegebenen [filter] zu den lokalen Filtern hinzu.
  void addLocalFilter(final IFilter filter) {
    _localFilters.add(filter);
    notifyListeners();
  }

  /// Setzt die [communityFilters].
  set communityFilters(final List<IFilter> filters) {
    _communityFilters
      ..clear()
      ..addAll(filters);
    notifyListeners();
  }

  /// Setzt den lokalen Filter-Speicher vollständig zurück und löscht alle enthaltenen Filter.
  void clear() {
    _selectedFilter = null;
    _selectedEditorFilter = null;
    _localFilters.clear();
    _communityFilters.clear();
    notifyListeners();
  }
}
