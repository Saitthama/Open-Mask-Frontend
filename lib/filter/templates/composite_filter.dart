import 'dart:ui';

import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';

/// Kombination mehrerer Filter.
/// Wendet alle enthaltenen Filter auf dasselbe Gesicht an.
class CompositeFilter extends Filter {
  /// Standard-Konstruktor.
  CompositeFilter({required super.meta})
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

  /// Liefert eine Liste von Filtern, welche auf das Gesicht angewandt werden.
  List<IFilter> get filterList => _filterList;

  @override
  void apply(final Face face, final Canvas canvas, final Size canvasSize,
      final Scale scale, final bool isFrontCamera) {
    for (final IFilter filter in _filterList) {
      filter.apply(face, canvas, canvasSize, scale, isFrontCamera);
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
