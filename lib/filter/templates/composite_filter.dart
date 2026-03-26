import 'dart:ui';

import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';

/// Kombination mehrerer Filter.
/// Wendet alle enthaltenen Filter auf dasselbe Gesicht an.
class CompositeFilter extends Filter {
  /// Standard-Konstruktor.
  CompositeFilter({super.id, required super.meta, super.parentId})
      : super(config: null, type: FilterType.composite);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory CompositeFilter.fromJSON(final Map<String, dynamic> json) {
    CompositeFilter compositeFilter =
        CompositeFilter(meta: FilterMeta.fromJson(json['meta']));

    List<IFilter> filterList = compositeFilter.filterList;
    List<Map<String, dynamic>> filterListAsJSON = json['filterList'];
    for (final Map<String, dynamic> filterAsJSON in filterListAsJSON) {
      filterList.add(FilterFactory.fromJSON(filterAsJSON));
    }

    return compositeFilter;
  }

  /// Liste von Filtern, welche auf das Gesicht angewandt werden.
  final List<IFilter> _filterList = <IFilter>[];

  /// Von außen unveränderliche Liste von Filtern, welche auf das Gesicht angewandt werden.
  List<IFilter> get filterList => List.unmodifiable(_filterList);

  /// Fügt den [filter] zur [filterList] hinzu.
  /// Liefert true zurück, falls die Operation erfolgreich war.
  /// Der [filter] darf nicht der [CompositeFilter] selbst sein.
  bool addFilter(final IFilter filter) {
    if (filter == this) {
      return false;
    }

    _filterList.add(filter);

    return true;
  }

  /// Entfernt den angegebenen [filter] aus der [filterList].
  /// Liefert true zurück, falls der [filter] vorhanden war, andernfalls false.
  bool removeFilter(final IFilter? filter) {
    return _filterList.remove(filter);
  }

  /// Verschiebt den Teilfilter am [oldIndex] zum [newIndex].
  void reorderFilter(final int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    IFilter item = _filterList.removeAt(oldIndex);
    _filterList.insert(newIndex, item);
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    for (final IFilter filter in _filterList) {
      filter.apply(face, canvas, fgc);
    }
  }

  /// Lädt alle externen Ressourcen für die Filter. <br>
  /// Der zurückgelieferte Boolean gibt an, ob die Ressourcen aller Bilder geladen werden konnten.
  @override
  Future<bool> load() async {
    bool loadedAll = true;
    for (final IFilter filter in _filterList) {
      loadedAll = await filter.load();
    }
    return loadedAll;
  }

  @override
  void dispose() {
    for (final IFilter filter in _filterList) {
      filter.dispose();
    }
  }

  @override
  CompositeFilter fork() {
    CompositeFilter fork = super.fork() as CompositeFilter;
    fork._filterList.addAll(_filterList.map((final filter) => filter.fork()));
    return fork;
  }

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = super.toJSON();

    List<Map<String, dynamic>> filterListAsJSON = <Map<String, dynamic>>[];
    for (final IFilter filter in _filterList) {
      filterListAsJSON.add(filter.toJSON());
    }
    json['filterList'] = filterListAsJSON;

    return json;
  }
}
