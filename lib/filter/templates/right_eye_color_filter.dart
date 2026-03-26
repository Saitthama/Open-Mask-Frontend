import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/color_filter.dart'
    as om_color_filter;

/// Farbfilter, der das rechte Auge ausfüllt. Wird nicht angezeigt, wenn das Auge geschlossen ist.
class RightEyeColorFilter extends om_color_filter.ColorFilter {
  /// Standard-Konstruktor.
  RightEyeColorFilter(
      {super.id, required super.meta, super.parentId, super.color})
      : super(type: FilterType.rightColorEye) {
    if (meta.iconIsDefault) {
      meta.icon = const Icon(
        Icons.remove_red_eye_rounded,
        color: Colors.black,
      );
    }
  }

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory RightEyeColorFilter.fromJSON(final Map<String, dynamic> json) {
    return om_color_filter.ColorFilter.fromJSON(json, RightEyeColorFilter.new)
        as RightEyeColorFilter;
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    FaceContour? faceContour = face.contours[FaceContourType.rightEye];
    if (faceContour == null || (face.rightEyeOpenProbability ?? 1) < 0.05) {
      return;
    }
    final maskPath = Path();
    final List<Offset> points = fgc.transformPoints(faceContour.points);
    maskPath.addPolygon(points, true);
    maskPath.fillType = PathFillType.evenOdd;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, 0.05 * maskPath.getBounds().width)
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(maskPath, paint);
  }
}
