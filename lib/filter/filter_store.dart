import 'package:flutter/cupertino.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';

/// Datenhalter-Klasse, welche globale Filterdaten speichert.
class FilterStore extends ChangeNotifier {
  /// Privater Konstruktor für das Singleton-Pattern.
  FilterStore._internal();

  /// Singleton-Instanz.
  static final FilterStore instance = FilterStore._internal();

  /// Der aktuell ausgewählte Filter.
  IFilter? _selectedFilter;

  /// Der Filter, der aktuell im Filter-Editor bearbeitet wird.
  IFilter? _currentlyEditedFilter;

  /// Der Filter, welcher aktuell im Editor ausgewählt ist.
  /// Kann sowohl [currentlyEditedFilter] als auch ein Teil eines [CompositeFilter] sein.
  IFilter? _selectedEditedFilter;

  /// Originale Referenz des [currentlyEditedFilter], welche zum Speichern dessen benutzt wird.
  IFilter? _savedEditedFilter;

  /// Alle lokalen Filter.
  final List<IFilter> _localFilters = [];

  /// Alle geladenen Community-Filter.
  final List<IFilter> _communityFilters = [];

  /// Der aktuell ausgewählte Filter.
  IFilter? get selectedFilter => _selectedFilter;

  /// Der Filter, der aktuell im Filter-Editor bearbeitet wird.
  IFilter? get currentlyEditedFilter => _currentlyEditedFilter;

  /// Der Filter, welcher aktuell im Editor ausgewählt ist.
  /// Kann sowohl [currentlyEditedFilter] als auch ein Teile eines [CompositeFilter] sein.
  IFilter? get selectedEditedFilter => _selectedEditedFilter;

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

  set currentlyEditedFilter(final IFilter? newSelectedEditorFilter) {
    if (newSelectedEditorFilter != _currentlyEditedFilter) {
      newSelectedEditorFilter?.load().then((final value) =>
          notifyListeners()); // Filter für die Bearbeitung asynchron laden
    }
    _currentlyEditedFilter = newSelectedEditorFilter;
    if (newSelectedEditorFilter == null) {
      _selectedEditedFilter = null;
    }
    notifyListeners();
  }

  set communityFilters(final List<IFilter> filters) {
    _communityFilters
      ..clear()
      ..addAll(filters);
    notifyListeners();
  }

  set selectedEditedFilter(final IFilter? selectedEditedFilter) {
    _selectedEditedFilter = selectedEditedFilter;
    notifyListeners();
  }

  /// Evaluiert, welcher Filter im Editor ausgewählt sein soll.
  void _evaluateSelectedEditedFilter() {
    if (currentlyEditedFilter != null) {
      if (currentlyEditedFilter is CompositeFilter &&
          (currentlyEditedFilter as CompositeFilter).filterList.isNotEmpty) {
        _selectedEditedFilter =
            (currentlyEditedFilter as CompositeFilter).filterList.last;
      } else {
        _selectedEditedFilter = currentlyEditedFilter;
      }
    }
  }

  /// Evaluiert, welcher Filter im Editor ausgewählt sein soll und ruft [notifyListeners] auf.
  void evaluateSelectedEditedFilter() {
    _evaluateSelectedEditedFilter();
    notifyListeners();
  }

  /// Fügt den angegebenen [filter] zu den lokalen Filtern hinzu.
  void addLocalFilter(final IFilter filter) {
    _localFilters.add(filter);
    notifyListeners();
  }

  /// Fügt den angegebenen Filter zu [currentlyEditedFilter] hinzu.
  /// Falls bereits ein Filter existiert, welcher nicht zusammengesetzt ist,
  /// wird der [currentlyEditedFilter] in einen [CompositeFilter] umgewandelt und der [filter] hinzugefügt.
  void addFilterToEdit(final IFilter filter) {
    if (_currentlyEditedFilter == null && filter is! CompositeFilter) {
      currentlyEditedFilter = filter;
    } else if (_currentlyEditedFilter is! CompositeFilter) {
      CompositeFilter composite =
          FilterFactory.create(FilterType.composite, isCreatedByUser: true)
              as CompositeFilter;
      if (_currentlyEditedFilter != null) {
        composite.addFilter(_currentlyEditedFilter!);
      }
      composite.addFilter(filter);
      currentlyEditedFilter = composite;
    } else {
      (_currentlyEditedFilter as CompositeFilter).addFilter(filter);
      filter.load().then((final value) => notifyListeners());
    }
    _evaluateSelectedEditedFilter();
    notifyListeners();
  }

  /// Erstellt einen neuen Filter zur Bearbeitung und fügt ihn zu [currentlyEditedFilter] hinzu.
  void createFilterToEdit(final FilterType type) {
    IFilter filter = FilterFactory.create(type, isCreatedByUser: true);
    FilterStore.instance.addFilterToEdit(filter);
  }

  /// Setzt den lokalen Filter-Speicher vollständig zurück und löscht alle enthaltenen Filter.
  void clear() {
    _selectedFilter = null;
    _currentlyEditedFilter = null;
    _localFilters.clear();
    _communityFilters.clear();
    notifyListeners();
  }
}
