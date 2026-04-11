import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/color_filter.dart';

/// Farbfilter, welcher die Konturen des Gesichts ausfüllt, aber die Augen ausschließt.
class ColorMaskFilter extends ColorFilter {
  /// Standard-Konstruktor.
  ColorMaskFilter(
      {required super.id,
      required super.uuid,
      required super.meta,
      super.parentUuid,
      super.color})
      : super(type: FilterType.colorMask) {
    meta.iconAsWidget = Image.asset('assets/images/filter/app_mask.png');
  }

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory ColorMaskFilter.fromJSON(final Map<String, dynamic> json) {
    return ColorFilter.fromJSON(json, ColorMaskFilter.new) as ColorMaskFilter;
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    final faceContour = face.contours[FaceContourType.face];
    final leftEyeContour = face.contours[FaceContourType.leftEye];
    final rightEyeContour = face.contours[FaceContourType.rightEye];
    if (faceContour == null) {
      return;
    }
    final maskPath = Path();
    final List<Offset> points = fgc.transformPoints(faceContour.points);
    maskPath.addPolygon(points, true);
    if (leftEyeContour != null && (face.leftEyeOpenProbability ?? 1) >= 0.05) {
      maskPath.addPolygon(fgc.transformPoints(leftEyeContour.points), true);
    }
    if (rightEyeContour != null &&
        (face.rightEyeOpenProbability ?? 1) >= 0.05) {
      maskPath.addPolygon(fgc.transformPoints(rightEyeContour.points), true);
    }
    //final lowerLipContour = face.contours[FaceContourType.lowerLipBottom];
    //final upperLipContour = face.contours[FaceContourType.upperLipTop];
    //if (lowerLipContour != null && upperLipContour != null) {
    //  final mouthOffsets = fgc.transformPoints(
    //      [...lowerLipContour.points, ...upperLipContour.points]);
    //  maskPath.addPolygon(mouthOffsets, true);
    //}
    maskPath.fillType = PathFillType.evenOdd;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, 0.01 * maskPath.getBounds().width)
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(maskPath, paint);
  }
}
