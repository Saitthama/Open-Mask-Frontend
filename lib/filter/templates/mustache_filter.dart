import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/image_filter.dart';

/// Filter, der einen Schnurrbart (Mustache) darstellt.
/// Bildfilter, der relativ zur Nase positioniert wird.
class MustacheFilter extends ImageFilter {
  /// Standard-Konstruktor.
  MustacheFilter(
      {super.id,
      required super.meta,
      required super.config,
      required super.filterImage})
      : super(
            type: FilterType.mustache,
            defaultAssetPath: 'assets/images/filter/mustache.png',
            defaultImageFilename: 'mustache.png',
            defaultOffset: const Offset(0.0, -10),
            defaultScale: const Scale(0.4, 0.4));

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory MustacheFilter.fromJSON(final Map<String, dynamic> json) {
    return ImageFilter.fromJSON(json, MustacheFilter.new) as MustacheFilter;
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    if (filterImage.image == null) return;

    // Beispiel: Nasensteg als Referenzpunkt
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];
    if (noseBase == null) return;

    // Position transformieren
    position = fgc.transformPoint(noseBase.position);
    super.apply(face, canvas, fgc);
  }
}
