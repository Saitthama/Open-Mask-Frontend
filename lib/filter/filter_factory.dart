import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/mustache_filter.dart';

import 'i_filter.dart';

class FilterFactory {
  /// Erzeugt einen Filter nach Typ und JSON‑Daten.
  static IFilter create(Map<String, dynamic> json) {
    String type = json['type'];
    switch (type) {
      case 'mustache':
        return MustacheFilter.fromJSON(json);
      case 'composite':
        return CompositeFilter.fromJSON(json);
      // TODO: weitere Filter
      default:
        throw ArgumentError('Unbekannter Filter-Typ $type');
    }
  }
}
