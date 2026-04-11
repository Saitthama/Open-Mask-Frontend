import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/color_filter.dart'
    as om_color_filter;

/// Farbfilter, der die Lippen ausfüllt.
class LipColorFilter extends om_color_filter.ColorFilter {
  /// Standard-Konstruktor.
  LipColorFilter(
      {required super.id,
      required super.uuid,
      required super.meta,
      super.parentUuid,
      super.color})
      : super(type: FilterType.lips);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory LipColorFilter.fromJSON(final Map<String, dynamic> json) {
    return om_color_filter.ColorFilter.fromJSON(json, LipColorFilter.new)
        as LipColorFilter;
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    FaceContour? upperLipTop = face.contours[FaceContourType.upperLipTop];
    FaceContour? upperLipBottom = face.contours[FaceContourType.upperLipBottom];
    FaceContour? lowerLipTop = face.contours[FaceContourType.lowerLipTop];
    FaceContour? lowerLipBottom = face.contours[FaceContourType.lowerLipBottom];
    if (upperLipTop == null ||
        upperLipBottom == null ||
        lowerLipTop == null ||
        lowerLipBottom == null) {
      return;
    }
    final maskPath = Path();
    final outerPoints =
        fgc.transformPoints([...upperLipTop.points, ...lowerLipBottom.points]);
    maskPath.addPolygon(outerPoints, true);
    final innerPoints =
        fgc.transformPoints([...upperLipBottom.points, ...lowerLipTop.points]);
    maskPath.addPolygon(innerPoints, true);
    maskPath.fillType = PathFillType.evenOdd;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, 0.025 * maskPath.getBounds().width)
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(maskPath, paint);
  }
}
