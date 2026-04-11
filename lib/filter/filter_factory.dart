import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/color_mask_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/hat_filter.dart';
import 'package:open_mask/filter/templates/left_eye_color_filter.dart';
import 'package:open_mask/filter/templates/left_eye_filter.dart';
import 'package:open_mask/filter/templates/lip_color_filter.dart';
import 'package:open_mask/filter/templates/mask_filter.dart';
import 'package:open_mask/filter/templates/mouth_color_filter.dart';
import 'package:open_mask/filter/templates/mouth_filter.dart';
import 'package:open_mask/filter/templates/mustache_filter.dart';
import 'package:open_mask/filter/templates/right_eye_color_filter.dart';
import 'package:open_mask/filter/templates/right_eye_filter.dart';
import 'package:uuid/uuid.dart';

import 'i_filter.dart';

/// Factory-Klasse zum Erstellen von konkreten Filter-Instanzen.
class FilterFactory {
  /// Erzeugt einen neuen Filter mit dem passenden Typ.
  static IFilter create(final FilterType type,
      {final bool isCreatedByUser = false}) {
    FilterMeta meta = isCreatedByUser
        ? FilterMeta(
            createdBy: AuthService.instance.user, createdAt: DateTime.now())
        : FilterMeta();
    meta.name = type.displayName;
    FilterConfig config = FilterConfig();
    String uuid = const Uuid().v4();
    return createType(uuid: uuid, type, meta, config: config);
  }

  /// Erzeugt einen neuen Filter mit dem passenden Typ und der angegebenen Konfiguration und den Metadaten.
  static IFilter createType(final FilterType type, final FilterMeta meta,
      {final int? id,
      final String? uuid,
      final FilterConfig? config,
      final String? parentUuid}) {
    String newFilterUuid = uuid ?? const Uuid().v4();
    switch (type) {
      case FilterType.composite:
        return CompositeFilter(
            id: id, uuid: newFilterUuid, meta: meta, parentUuid: parentUuid);
      case FilterType.mustache:
        return MustacheFilter(
            id: id,
            uuid: newFilterUuid,
            meta: meta,
            config: config ?? FilterConfig(),
            parentUuid: parentUuid,
            filterImage: null);
      case FilterType.hat:
        return HatFilter(
            id: id,
            uuid: newFilterUuid,
            meta: meta,
            config: config ?? FilterConfig(),
            parentUuid: parentUuid,
            filterImage: null);
      case FilterType.mask:
        return MaskFilter(
            id: id,
            uuid: newFilterUuid,
            meta: meta,
            config: config ?? FilterConfig(),
            parentUuid: parentUuid,
            filterImage: null);
      case FilterType.leftEye:
        return LeftEyeFilter(
            id: id,
            uuid: newFilterUuid,
            meta: meta,
            config: config ?? FilterConfig(),
            parentUuid: parentUuid,
            filterImage: null);
      case FilterType.rightEye:
        return RightEyeFilter(
            id: id,
            uuid: newFilterUuid,
            meta: meta,
            config: config ?? FilterConfig(),
            parentUuid: parentUuid,
            filterImage: null);
      case FilterType.rightColorEye:
        return RightEyeColorFilter(
            id: id, uuid: newFilterUuid, meta: meta, parentUuid: parentUuid);
      case FilterType.leftColorEye:
        return LeftEyeColorFilter(
            id: id, uuid: newFilterUuid, meta: meta, parentUuid: parentUuid);
      case FilterType.colorMask:
        return ColorMaskFilter(
            id: id, uuid: newFilterUuid, meta: meta, parentUuid: parentUuid);
      case FilterType.lips:
        return LipColorFilter(
            id: id, uuid: newFilterUuid, meta: meta, parentUuid: parentUuid);
      case FilterType.innerMouth:
        return MouthColorFilter(
            id: id, uuid: newFilterUuid, meta: meta, parentUuid: parentUuid);
      case FilterType.mouth:
        return MouthFilter(
            id: id,
            uuid: newFilterUuid,
            meta: meta,
            config: config ?? FilterConfig(),
            parentUuid: parentUuid,
            filterImage: null);
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
      case FilterType.leftEye:
        return LeftEyeFilter.fromJSON(json);
      case FilterType.rightEye:
        return RightEyeFilter.fromJSON(json);
      case FilterType.rightColorEye:
        return RightEyeColorFilter.fromJSON(json);
      case FilterType.leftColorEye:
        return LeftEyeColorFilter.fromJSON(json);
      case FilterType.colorMask:
        return ColorMaskFilter.fromJSON(json);
      case FilterType.lips:
        return LipColorFilter.fromJSON(json);
      case FilterType.innerMouth:
        return MouthColorFilter.fromJSON(json);
      case FilterType.mouth:
        return MouthFilter.fromJSON(json);
      // TODO: weitere Filterarten
    }
  }
}
