import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';

/// Abstrakte Basisklasse für alle konkreten Filter.
/// Enthält Metadaten, Konfiguration und Filtertyp.
abstract class Filter implements IFilter {
  /// Standard-Konstruktor.
  Filter(
      {this.id,
      required this.meta,
      required final config,
      required this.type,
      this.parentId})
      : _config = config;

  /// Eindeutige Datenbank-ID des Filters.
  final int? id;

  /// Metadaten wie Name, Ersteller und Veröffentlichungsstatus.
  final FilterMeta meta;

  /// Gemeinsame Konfiguration aller Filtertypen.
  final FilterConfig? _config;

  @override
  FilterConfig? get config => _config;

  /// Typ des Filters (z. B. mustache, hat, mask).
  final FilterType type;

  /// Id des Partent-Filters, falls der Filter ein Fork ist.
  final int? parentId;

  @override
  Map<String, dynamic> toJSON() => {
        if (id != null) 'id': id,
        'meta': meta.toJSON(),
        'config': config?.toJSON() ?? {},
        'type': type.toString(),
        if (parentId != null) 'parentId': parentId,
        // TODO: evtl. wichtige Eigenschaften wie Ersteller und Name aus der Datenbank laden, statt der Id
      };
}
