import 'package:flutter/material.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/templates/filter.dart';

/// Abstrakte Basisklasse für Filter, die in einer Farbe angezeigt werden.
abstract class ColorFilter extends Filter {
  /// Standard-Konstruktor.
  ColorFilter(
      {super.id,
      required super.meta,
      required super.type,
      this.color =
          const Color.from(alpha: 255, red: 255, green: 255, blue: 255)})
      : super(config: null);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory ColorFilter.fromJSON(
      final Map<String, dynamic> json,
      final ColorFilter Function(
              {required int? id,
              required FilterMeta meta,
              required Color color})
          filterCreator) {
    Map<String, dynamic> colorJson = json['color'];

    return filterCreator(
        id: int.tryParse(json['id']),
        meta: FilterMeta.fromJson(json['meta']),
        color: Color.from(
            alpha: colorJson['alpha'],
            red: colorJson['red'],
            green: colorJson['green'],
            blue: colorJson['blue']));
  }

  /// Farbe, die verwendet werden soll.
  Color color;

  @override
  Map<String, dynamic> toJSON() => {
        ...super.toJSON(),
        'color': {
          'alpha': color.a,
          'red': color.r,
          'green': color.g,
          'blue': color.b
        }
      };

  @override
  Future<bool> load() async {
    return true;
  }
}
