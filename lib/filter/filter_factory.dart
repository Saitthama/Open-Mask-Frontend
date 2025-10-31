import 'package:open_mask/filter/configs/image_filter_config.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/hat_filter.dart';
import 'package:open_mask/filter/templates/mask_filter.dart';
import 'package:open_mask/filter/templates/mustache_filter.dart';

import 'i_filter.dart';

/// Factory-Klasse zum Erstellen von konkreten Filter-Instanzen.
class FilterFactory {
  /// Erzeugt einen neuen Filter mit dem passenden Typ.
  static IFilter create(final FilterType type) {
    switch (type) {
      case FilterType.composite:
        return CompositeFilter(meta: FilterMeta());
      case FilterType.mustache:
        return MustacheFilter(
            meta: FilterMeta(),
            config: ImageFilterConfig(
                imagePath: MustacheFilter.defaultImagePath,
                offset: MustacheFilter.defaultOffset,
                scale: MustacheFilter.defaultScale));
      case FilterType.hat:
        return HatFilter(
            meta: FilterMeta(),
            config: ImageFilterConfig(imagePath: HatFilter.defaultImagePath));
      case FilterType.mask:
        return MaskFilter(
            meta: FilterMeta(),
            config: ImageFilterConfig(
                imagePath: MaskFilter.defaultImagePath,
                offset: MaskFilter.defaultOffset));
      // TODO: weitere Filterarten
    }
  }

  /// Stellt einen Filter aus einem JSON-Objekt wieder her.
  static IFilter fromJSON(final Map<String, dynamic> json) {
    FilterType filterType = filterTypeFromString(json['type']);
    switch (filterType) {
      case FilterType.composite:
        return CompositeFilter.fromJSON(json);
      case FilterType.mustache:
        return MustacheFilter.fromJSON(json);
      case FilterType.hat:
        return HatFilter.fromJSON(json);
      case FilterType.mask:
        return MaskFilter.fromJSON(json);
      // TODO: weitere Filterarten
    }
  }
}
