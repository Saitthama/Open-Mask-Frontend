import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/geometry_service.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/image_filter.dart';

/// Filter, welcher eine Maske über das Gesicht legt (Positionierung basierend auf der Bounding-Box des Gesichts).
class MouthFilter extends ImageFilter {
  /// Standard-Konstruktor.
  MouthFilter(
      {super.id,
      required super.meta,
      required super.config,
      required super.filterImage})
      : super(
            type: FilterType.mouth,
            defaultAssetPath: 'assets/images/filter/mouth.png',
            defaultImageFilename: 'mouth.png',
            defaultOffset: Offset.zero,
            defaultScale: const Scale(1.3, 1.0));

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory MouthFilter.fromJSON(final Map<String, dynamic> json) {
    return ImageFilter.fromJSON(json, MouthFilter.new) as MouthFilter;
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    if (filterImage.image == null) return;

    final leftMouth = face.landmarks[FaceLandmarkType.leftMouth];
    final rightMouth = face.landmarks[FaceLandmarkType.rightMouth];
    if (leftMouth == null || rightMouth == null) {
      return;
    }

    // Gesichtsdaten
    final leftMouthPosition = fgc.transformPoint(leftMouth.position);
    final rightMouthPosition = fgc.transformPoint(rightMouth.position);
    final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth];
    final bottomMouthPosition =
        bottomMouth != null ? fgc.transformPoint(bottomMouth.position) : null;
    final mouthMiddle =
        GeometryService.midpoint(leftMouthPosition, rightMouthPosition);
    final mouthHeight = bottomMouthPosition != null
        ? (mouthMiddle - bottomMouthPosition).distance
        : null;
    position = mouthMiddle;
    filterSize = Size(
        (leftMouthPosition - rightMouthPosition).distance + (mouthHeight ?? 0),
        face.boundingBox.height);
    super.apply(face, canvas, fgc);
  }
}
