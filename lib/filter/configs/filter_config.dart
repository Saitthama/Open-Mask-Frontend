import 'dart:ui';

import 'package:open_mask/data/model/scale.dart';

/// Allgemeine Parameter für die Positionierung und Transformation eines Filters.
class FilterConfig {
  FilterConfig(
      {this.offset = standardOffset,
      this.scale = standardScale,
      this.rotation = standardRotation,
      this.opacity = standardOpacity});

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory FilterConfig.fromJSON(final Map<String, dynamic> json) =>
      FilterConfig(
          offset: Offset(double.tryParse(json['offsetX']) ?? standardOffset.dx,
              double.tryParse(json['offsetY']) ?? standardOffset.dy),
          scale: Scale(double.tryParse(json['scaleX']) ?? standardScale.scaleX,
              double.tryParse(json['scaleY']) ?? standardScale.scaleY),
          rotation: double.tryParse(json['rotation']) ?? standardRotation,
          opacity: double.tryParse(json['opacity']) ?? standardOpacity);

  /// Standardmäßiges Offset ([offset]).
  static const Offset standardOffset = Offset.zero;

  /// Standardmäßige Skalierung ([scale]).
  static const Scale standardScale = Scale(1.0, 1.0);

  /// Standardmäßige Rotation ([rotation]).
  static const double standardRotation = 0.0;

  /// Standardmäßige Transparenz ([opacity]).
  static const double standardOpacity = 1.0;

  /// Gibt die relative Positionierung des Filters im Bezug zum je nach Filterart unterschiedlichen Bezugspunkt an.
  Offset offset;

  /// Stellt das Verhältnis zwischen Gesichtsgröße und Filter-Größe dar.
  Scale scale;

  /// Gibt die Rotation des Filters an.
  double rotation;

  /// Gibt die Transparenz des Filters an.
  double opacity;

  /// Methode zur JSON‑Serialisierung.
  Map<String, dynamic> toJSON() => {
        'offsetX': offset.dx,
        'offsetY': offset.dy,
        'scaleX': scale.scaleX,
        'scaleY': scale.scaleY,
        'rotation': rotation,
        'opacity': opacity
      };
}
