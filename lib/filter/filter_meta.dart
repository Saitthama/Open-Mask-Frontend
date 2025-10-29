import 'package:open_mask/data/model/user.dart';

/// Enthält alle Metadaten eines Filters.
class FilterMeta {
  FilterMeta(
      {this.id,
      required this.name,
      required this.description,
      this.createdBy,
      this.parentId,
      this.createdAt,
      this.updatedAt,
      this.published = false});

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory FilterMeta.fromJson(final Map<String, dynamic> json) => FilterMeta(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      published: json['published'],
      parentId: json['parentId'],
      createdBy: json['createdBy'] ?? User.fromJson(json['createdBy']),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']));

  final int? id;

  /// Name des Filters.
  String name;

  /// Beschreibung des Filters.
  String description;

  /// Ersteller des Filters.
  final User? createdBy;

  /// Id der Parent-Filter-Meta-Daten, falls der Filter ein Fork ist.
  final int? parentId;

  /// Erstellungsdatum des Filters.
  final DateTime? createdAt;

  /// Datum, an dem der Filter zuletzt veröndert wurde.
  DateTime? updatedAt;

  /// Veröffentlichungsstatus, welcher aussagt, ob der Filter veröffentlich worden ist oder nicht.
  bool published;

  /// Methode zur JSON‑Serialisierung für die Backend-Kommunikation.
  Map<String, dynamic> toJSON() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
        if (createdBy != null) 'createdById': createdBy?.id,
        if (parentId != null) 'parentId': parentId,
        if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
        'published': published
      };

  /// Methode zur JSON-Serialisierung für die lokale Speicherung oder den Export
  Map<String, dynamic> toExportAsJSON() => {
        'name': name,
        'description': description,
        'published': published,
        'createdBy': createdBy?.toJSON(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
