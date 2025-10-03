import 'dart:ui';

import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/i_filter.dart';

class CompositeFilter implements IFilter {
  CompositeFilter();

  /// Keine Config
  @override
  FilterConfig? get config => null;

  final List<IFilter> _filterList = <IFilter>[];

  List<IFilter> get filterList => _filterList;

  @override
  void apply(Face face, Canvas canvas, Size canvasSize, Scale scale,
      bool isFrontCamera) {
    for (IFilter filter in _filterList) {
      filter.apply(face, canvas, canvasSize, scale, isFrontCamera);
    }
  }

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      'type': 'composite',
    };

    List<Map<String, dynamic>> filterListAsJSON = <Map<String, dynamic>>[];
    for (IFilter filter in _filterList) {
      filterListAsJSON.add(filter.toJSON());
    }
    json['filterList'] = filterListAsJSON;

    return json;
  }

  factory CompositeFilter.fromJSON(Map<String, dynamic> json) {
    CompositeFilter compositeFilter = CompositeFilter();

    List<IFilter> filterList = compositeFilter.filterList;
    List<Map<String, dynamic>> filterListAsJSON = json['filterList'];
    for (Map<String, dynamic> filterAsJSON in filterListAsJSON) {
      filterList.add(FilterFactory.create(filterAsJSON));
    }

    return compositeFilter;
  }
}
