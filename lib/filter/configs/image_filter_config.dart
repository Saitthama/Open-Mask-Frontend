import 'dart:ui';

import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/filter/configs/filter_config.dart';

/// Erweiterte Konfiguration für bildbasierte Filter.
/// Enthält zusätzlich den Pfad oder die Quelle des Bildes.
class ImageFilterConfig extends FilterConfig {
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
              double.tryParse(json['offsetX']) ??
                  FilterConfig.standardOffset.dx,
              double.tryParse(json['offsetY']) ??
                  FilterConfig.standardOffset.dy),
          scale: Scale(
              double.tryParse(json['scaleX']) ??
                  FilterConfig.standardScale.scaleX,
              double.tryParse(json['scaleY']) ??
                  FilterConfig.standardScale.scaleY),
          rotation: double.tryParse(json['rotation']) ??
              FilterConfig.standardRotation,
          opacity:
              double.tryParse(json['opacity']) ?? FilterConfig.standardOpacity,
          imagePath: json['imagePath']);

  /// Pfad oder die Quelle des Bildes.
  String? imagePath;

  @override
  Map<String, dynamic> toJSON() => {
        ...super.toJSON(),
        'imagePath': imagePath,
      };
}
