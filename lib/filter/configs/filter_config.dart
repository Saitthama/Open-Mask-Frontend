import 'dart:ui';

import 'package:open_mask/data/model/scale.dart';

/// Allgemeine Parameter für die Positionierung und Transformation eines Filters.
class FilterConfig {
  /// Standard-Konstruktor.
  FilterConfig(
      {this.offset = defaultOffset,
      this.scale = defaultScale,
      this.rotation = defaultRotation,
      this.opacity = defaultOpacity});

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory FilterConfig.fromJSON(final Map<String, dynamic> json) =>
      FilterConfig(
          offset: Offset(double.tryParse(json['offsetX']) ?? defaultOffset.dx,
              double.tryParse(json['offsetY']) ?? defaultOffset.dy),
          scale: Scale(double.tryParse(json['scaleX']) ?? defaultScale.scaleX,
              double.tryParse(json['scaleY']) ?? defaultScale.scaleY),
          rotation: double.tryParse(json['rotation']) ?? defaultRotation,
          opacity: double.tryParse(json['opacity']) ?? defaultOpacity);

  /// Standardmäßiges Offset ([offset]).
  static const Offset defaultOffset = Offset.zero;

  /// Standardmäßige Skalierung ([scale]).
  static const Scale defaultScale = Scale(1.0, 1.0);

  /// Standardmäßige Rotation ([rotation]).
  static const double defaultRotation = 0.0;

  /// Standardmäßige Transparenz ([opacity]).
  static const double defaultOpacity = 1.0;

  /// Gibt die relative Abweichung des Filters vom je nach Filterart unterschiedlichem Bezugspunkt an.
  Offset offset;

  /// Stellt das Verhältnis zwischen Gesichtsgröße und Filter-Größe dar.
  Scale scale;

  /// Gibt die Rotation des Filters in Grad an.
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
