import 'package:flutter/material.dart';
import 'package:open_mask/data/model/user.dart';
import 'package:open_mask/data/services/auth_service.dart';

/// Enthält alle Metadaten eines Filters.
class FilterMeta {
  /// Standard-Konstruktor.
  FilterMeta(
      {final String name = defaultName,
      final String description = defaultDescription,
      this.createdBy,
      this.createdAt,
      final DateTime? updatedAt,
      final bool isPublic = false,
      final Widget? icon})
      : _name = name,
        _description = description,
        _updatedAt = updatedAt ?? createdAt,
        _isPublic = isPublic,
        _icon = icon;

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory FilterMeta.fromJson(final Map<String, dynamic> json) => FilterMeta(
      name: json['name'],
      description: json['description'],
      isPublic: json['published'],
      createdBy:
          json['createdBy'] == null ? null : User.fromJson(json['createdBy']),
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(json['createdAt']),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt']));

  /// Standardmäßiger Name ([name]).
  static const String defaultName = 'Neuer Filter';

  /// Standardmäßige Beschreibung ([description]).
  static const String defaultDescription = 'Neu ersteller Filter';

  /// Name des Filters.
  String _name;

  /// Beschreibung des Filters.
  String _description;

  /// Ersteller des Filters.
  final User? createdBy;

  /// Erstellungszeitpunkt des Filters.
  final DateTime? createdAt;

  /// Datum, an dem der Filter zuletzt verändert wurde.
  DateTime? _updatedAt;

  /// Veröffentlichungsstatus, welcher aussagt, ob der Filter veröffentlich worden ist oder nicht.
  bool _isPublic;

  /// Icon des Filters als [Widget] (standardmäßig null).
  Widget? _icon;

  /// Name des Filters.
  String get name => _name;

  /// Name des Filters.
  set name(final String value) {
    _name = value;
    _updatedAt = DateTime.now();
  }

  /// Beschreibung des Filters.
  String get description => _description;

  /// Beschreibung des Filters.
  set description(final String value) {
    _description = value;
    _updatedAt = DateTime.now();
  }

  /// Datum, an dem der Filter zuletzt verändert wurde.
  DateTime? get updatedAt => _updatedAt ?? createdAt;

  /// Veröffentlichungsstatus, welcher aussagt, ob der Filter veröffentlich worden ist oder nicht.
  bool get isPublic => _isPublic;

  /// Veröffentlichungsstatus, welcher aussagt, ob der Filter veröffentlich worden ist oder nicht.
  set isPublic(final bool value) {
    _isPublic = value;
    _updatedAt = DateTime.now();
  }

  /// Icon des Filters als [Widget]. Falls dieses noch nicht gesetzt wurde, wird das App-Logo benutzt.
  Widget get icon =>
      _icon ?? Image.asset('assets/images/icons/app-icon_round.png');

  /// Gibt an, ob das Icon intern null ist und [icon] den Default-Wert zurückgibt.
  bool get iconIsDefault => _icon == null;

  /// Icon des Filters als [Widget].
  set icon(final Widget? newIcon) {
    _icon = newIcon;
    _updatedAt = DateTime.now();
  }

  /// Methode zur JSON‑Serialisierung für die Backend-Kommunikation.
  Map<String, dynamic> toJSON() => {
        'name': name,
        'description': description,
        'published': isPublic,
        if (createdBy != null) 'createdById': createdBy?.id,
        if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      };

  /// Methode zur JSON-Serialisierung für die lokale Speicherung oder den Export.
  Map<String, dynamic> toExportAsJSON() => {
        'name': name,
        'description': description,
        'published': isPublic,
        if (createdBy != null) 'createdBy': createdBy?.toJSON(),
        if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      };

  /// Erstellt eine Kopie der Metadaten.
  FilterMeta fork({final bool createdByUser = true}) {
    return FilterMeta(
      name: _name,
      description: _description,
      createdBy: createdByUser ? AuthService.instance.user : createdBy,
      createdAt: DateTime.now(),
      isPublic: _isPublic,
      icon: _icon,
    );
  }
}
