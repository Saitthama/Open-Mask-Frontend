import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/image_filter.dart';

/// Filter, dessen Position auf dem linken Auge basiert. Wird nicht angezeigt, wenn das Auge geschlossen ist.
class LeftEyeFilter extends ImageFilter {
  /// Standard-Konstruktor.
  LeftEyeFilter(
      {super.id,
      required super.meta,
      required super.config,
      super.parentId,
      required super.filterImage})
      : super(
            type: FilterType.leftEye,
            defaultAssetPath: 'assets/images/filter/red_glowing_eye.png',
            defaultImageFilename: 'eye.png');

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory LeftEyeFilter.fromJSON(final Map<String, dynamic> json) {
    return ImageFilter.fromJSON(json, LeftEyeFilter.new) as LeftEyeFilter;
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    final FaceLandmark? leftEye = face.landmarks[FaceLandmarkType.leftEye];
    if (leftEye == null || (face.leftEyeOpenProbability ?? 1) < 0.05) {
      return;
    }
    // Position transformieren
    position = fgc.transformPoint(leftEye.position);
    super.apply(face, canvas, fgc);
  }
}
