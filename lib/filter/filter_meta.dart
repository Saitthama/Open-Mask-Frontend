import 'package:flutter/material.dart';
import 'package:open_mask/data/model/user.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/filter/filter_image.dart';

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
      final FilterImage? icon})
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
            : DateTime.tryParse(json['updatedAt']),
        icon: json['icon'] != null ? FilterImage.fromJSON(json['icon']) : null,
      );

  /// Standardmäßiger Name ([name]).
  static const String defaultName = 'Neuer Filter';

  /// Standardmäßige Beschreibung ([description]).
  static const String defaultDescription = 'Neu ersteller Filter';

  /// Gibt die Icon-Größe an, auf die das Icon standardmäßig skaliert werden soll.
  static const Size iconSize = Size(256, 256);

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
  FilterImage? _icon;

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

  /// Icon des Filters als [FilterImage].
  FilterImage? get icon => _icon;

  set icon(final FilterImage? newIcon) {
    _icon = newIcon;
    _updatedAt = DateTime.now();
  }

  /// Skaliert das Icon auf die [iconSize]. <p>
  /// Gibt true zurück, wenn es neu skaliert wurde </p>
  Future<bool> resizeIcon() async {
    if (icon == null) return false;
    final data = icon?.rawData;
    await icon?.resize(iconSize);
    if (data == icon?.rawData) return false;
    _updatedAt = DateTime.now();
    return true;
  }

  /// Icon als [Widget], welches verwendet wird, falls [icon] nicht gesetzt ist.
  Widget? _iconAsWidget = Image.asset('assets/images/icons/app-icon_round.png');

  /// Icon des Filters als [Widget]. Wird aus dem [icon] generiert, falls dieses vorhanden ist.
  /// Falls dieses noch nicht gesetzt wurde, wird der interne Wert des [iconAsWidget] oder das App-Logo benutzt.
  Widget get iconAsWidget =>
      _icon?.imageAsWidget ??
      _iconAsWidget ??
      Image.asset('assets/images/icons/app-icon_round.png');

  /// Icon als [Widget], welches verwendet wird, falls [icon] nicht gesetzt ist.
  set iconAsWidget(final Widget? iconAsWidget) {
    _iconAsWidget = iconAsWidget;
  }

  /// Methode zur JSON‑Serialisierung für die Backend-Kommunikation.
  Map<String, dynamic> toJSON() => {
        'name': name,
        'description': description,
        'published': isPublic,
        if (createdBy != null) 'createdById': createdBy?.id,
        if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
        if (_icon != null) 'icon': _icon?.toJSON(),
      };

  /// Methode zur JSON-Serialisierung für die lokale Speicherung oder den Export.
  Map<String, dynamic> toExportAsJSON() => {
        'name': name,
        'description': description,
        'published': isPublic,
        if (createdBy != null) 'createdBy': createdBy?.toJSON(),
        if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
        if (_icon != null) 'icon': _icon?.toJSON(),
      };

  /// Erstellt eine Kopie der Metadaten.
  FilterMeta fork({final bool createdByUser = true}) {
    return FilterMeta(
      name: _name,
      description: _description,
      createdBy: createdByUser ? AuthService.instance.user : createdBy,
      createdAt: DateTime.now(),
      isPublic: _isPublic,
      icon: _icon?.fork(),
    ).._iconAsWidget = _iconAsWidget;
  }
}
