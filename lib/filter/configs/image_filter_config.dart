import 'dart:ui';

import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/filter/configs/filter_config.dart';

/// Erweiterte Konfiguration für bildbasierte Filter.
/// Enthält zusätzlich den Pfad oder die Quelle des Bildes.
class ImageFilterConfig extends FilterConfig {
  /// Standard-Konstruktor.
  ImageFilterConfig(
      {this.imagePath,
      super.offset,
      super.scale,
      super.rotation,
      super.opacity});

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory ImageFilterConfig.fromJSON(final Map<String, dynamic> json) =>
      ImageFilterConfig(
          offset: Offset(
              double.tryParse(json['offsetX']) ?? FilterConfig.defaultOffset.dx,
              double.tryParse(json['offsetY']) ??
                  FilterConfig.defaultOffset.dy),
          scale: Scale(
              double.tryParse(json['scaleX']) ??
                  FilterConfig.defaultScale.scaleX,
              double.tryParse(json['scaleY']) ??
                  FilterConfig.defaultScale.scaleY),
          rotation:
              double.tryParse(json['rotation']) ?? FilterConfig.defaultRotation,
          opacity:
              double.tryParse(json['opacity']) ?? FilterConfig.defaultOpacity,
          imagePath: json['imagePath']);

  /// Pfad oder die Quelle des Bildes.
  String? imagePath;

  @override
  Map<String, dynamic> toJSON() => {
        ...super.toJSON(),
        'imagePath': imagePath,
      };
}
