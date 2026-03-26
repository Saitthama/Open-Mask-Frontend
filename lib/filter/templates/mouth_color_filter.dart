import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/color_filter.dart'
    as om_color_filter;

/// Farbfilter, der das innere des Mundes ausfüllt.
class MouthColorFilter extends om_color_filter.ColorFilter {
  /// Standard-Konstruktor.
  MouthColorFilter({super.id, required super.meta, super.parentId, super.color})
      : super(type: FilterType.innerMouth);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory MouthColorFilter.fromJSON(final Map<String, dynamic> json) {
    return om_color_filter.ColorFilter.fromJSON(json, MouthColorFilter.new)
        as MouthColorFilter;
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    FaceContour? upperLipBottom = face.contours[FaceContourType.upperLipBottom];
    FaceContour? lowerLipTop = face.contours[FaceContourType.lowerLipTop];
    if (upperLipBottom == null || lowerLipTop == null) {
      return;
    }
    final maskPath = Path();
    final points =
        fgc.transformPoints([...upperLipBottom.points, ...lowerLipTop.points]);
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
