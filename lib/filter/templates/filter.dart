import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';

/// Abstrakte Basisklasse für alle konkreten Filter.
/// Enthält Metadaten, Konfiguration und Filtertyp.
abstract class Filter implements IFilter {
  /// Standard-Konstruktor.
  Filter(
      {required this.id,
      required this.uuid,
      required this.meta,
      required final config,
      required this.type,
      required this.parentUuid})
      : _config = config;

  /// Eindeutige Datenbank-ID des Filters.
  final int? id;

  /// Eine UUID zur eindeutigen Identifikation des Filters.
  final String uuid;

  /// Metadaten wie Name, Ersteller und Veröffentlichungsstatus.
  final FilterMeta meta;

  /// Gemeinsame Konfiguration aller Filtertypen.
  final FilterConfig? _config;

  @override
  FilterConfig? get config => _config;

  /// Typ des Filters (z.B. mustache, hat, mask).
  final FilterType type;

  /// Id des Parent-Filters, falls der Filter ein Fork ist.
  final String? parentUuid;

  @override
  Filter fork({final bool createdByUser = true}) {
    return FilterFactory.createType(
        type, meta.fork(createdByUser: createdByUser),
        config: config?.fork(), parentUuid: uuid) as Filter;
  }

  @override
  Map<String, dynamic> toJSON() => {
        if (id != null) 'id': id,
        'uuid': uuid,
        'meta': meta.toJSON(),
        'config': config?.toJSON() ?? {},
        'type': type.name,
        if (parentUuid != null) 'parentUUID': parentUuid,
      };

  @override
  Map<String, dynamic> toExportAsJSON() {
    Map<String, dynamic> json = toJSON();
    json['meta'] = meta.toExportAsJSON();
    return json;
  }
}
