import 'package:flutter/material.dart';
import 'package:open_mask/data/model/user.dart';

/// Enthält alle Metadaten eines Filters.
class FilterMeta {
  /// Standard-Konstruktor.
  FilterMeta(
      {this.name = defaultName,
      this.description = defaultDescription,
      this.createdBy,
      this.createdAt,
      this.updatedAt,
      this.isPublic = false,
      final Widget? icon})
      : _icon = icon;

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory FilterMeta.fromJson(final Map<String, dynamic> json) => FilterMeta(
      name: json['name'],
      description: json['description'],
      isPublic: json['published'],
      createdBy: json['createdBy'] ?? User.fromJson(json['createdBy']),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']));

  /// Standardmäßiger Name ([name]).
  static const String defaultName = 'Neuer Filter';

  /// Standardmäßige Beschreibung ([description]).
  static const String defaultDescription = 'Neu ersteller Filter';

  /// Name des Filters.
  String name;

  /// Beschreibung des Filters.
  String description;

  /// Ersteller des Filters.
  final User? createdBy;

  /// Erstellungsdatum des Filters.
  final DateTime? createdAt;

  /// Datum, an dem der Filter zuletzt veröndert wurde.
  DateTime? updatedAt;

  /// Veröffentlichungsstatus, welcher aussagt, ob der Filter veröffentlich worden ist oder nicht.
  bool isPublic;

  /// Icon des Filters als [Widget] (standardmäßig null).
  Widget? _icon;

  /// Icon des Filters als [Widget]. Falls dieses noch nicht gesetzt wurde, wird das App-Logo benutzt.
  Widget get icon =>
      _icon ?? Image.asset('assets/images/icons/app-icon_round.png');

  set icon(final Widget? newIcon) {
    _icon = newIcon;
  }

  /// Methode zur JSON‑Serialisierung für die Backend-Kommunikation.
  Map<String, dynamic> toJSON() => {
        'name': name,
        'description': description,
        if (createdBy != null) 'createdById': createdBy?.id,
        if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
        'published': isPublic
      };

  /// Methode zur JSON-Serialisierung für die lokale Speicherung oder den Export
  Map<String, dynamic> toExportAsJSON() => {
        'name': name,
        'description': description,
        'published': isPublic,
        'createdBy': createdBy?.toJSON(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
