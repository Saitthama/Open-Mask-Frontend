import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';

/// Ein [CustomPainter], welcher die Gesichtserkennung des [FaceDetectionService] visualisiert.
class FaceMarkingsPainter extends CustomPainter {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>[faces] ist die Liste der analysierten Gesichter, die visualisiert werden sollen. </li>
  ///   <li>Die [imageSize] gibt die Größe des Originalbildes an. </li>
  ///   <li>[isFrontCamera] gibt an, ob die verwendete Kamera die Frontkamera ist und das Preview daher gespiegelt ist. </li>
  ///   <li>[showFaceBox] gibt an, ob Markierungen angezeigt werden sollen. </li>
  ///   <li>[showLandmarks] gibt an, ob erkannte Punkte wie Nasen, Augen, Ohren, etc. ebenfalls visualisiert werden sollen. </li>
  ///   <li>[showContours] gibt an, ob Gesichtskonturen ebenfalls visualisiert werden sollen. </li>
  ///   <li>[contourColors] ordnet den Gesichtskonturen Farben zu und nimmt, wenn nicht gesetzt, den Wert von [standardContourColors] ein.
  /// </ul>
  FaceMarkingsPainter(final List<Face> faces, final Size imageSize,
      {final bool isFrontCamera = true,
      final bool showFaceBox = true,
      final bool showLandmarks = true,
      final bool showContours = false,
      final Map<FaceContourType, Color>? contourColors})
      : _faces = faces,
        _imageSize = imageSize,
        _showFaceBox = showFaceBox,
        _showLandmarks = showLandmarks,
        _showContours = showContours,
        _isFrontCamera = isFrontCamera,
        contourColors =
            (contourColors == null) ? standardContourColors : contourColors;

  /// Standardmäßige Farbzuordnungen ([contourColors]) für Gesichtskonturen.
  static const Map<FaceContourType, Color> standardContourColors =
      <FaceContourType, Color>{
    FaceContourType.face: Colors.blueAccent,
    FaceContourType.leftEyebrowTop: Colors.redAccent,
    FaceContourType.leftEyebrowBottom: Colors.orangeAccent,
    FaceContourType.rightEyebrowTop: Colors.redAccent,
    FaceContourType.rightEyebrowBottom: Colors.orangeAccent,
    FaceContourType.leftEye: Colors.lightBlue,
    FaceContourType.rightEye: Colors.lightBlue,
    FaceContourType.upperLipTop: Colors.cyanAccent,
    FaceContourType.upperLipBottom: Colors.lightGreen,
    FaceContourType.lowerLipTop: Colors.lightGreen,
    FaceContourType.lowerLipBottom: Colors.cyanAccent,
    FaceContourType.noseBridge: Colors.deepPurple,
    FaceContourType.noseBottom: Colors.teal,
    FaceContourType.leftCheek: Colors.lightBlueAccent,
    FaceContourType.rightCheek: Colors.lightBlueAccent
  };

  /// Ordnet den Gesichtskonturen Farben zu.
  /// Nimmt den Wert von [standardContourColors] ein, wenn es nicht im Konstruktor gesetzt wird.
  final Map<FaceContourType, Color> contourColors;

  /// Liste der analysierten Gesichter, die visualisiert werden sollen.
  final List<Face> _faces;

  /// Größe des Originalbildes.
  final Size _imageSize;

  /// Gibt an, ob die verwendete Kamera die Frontkamera ist und das Preview daher gespiegelt ist.
  final bool _isFrontCamera;

  /// Gibt an, ob die Gesichtsbox angezeigt werden soll.
  final bool _showFaceBox;

  /// Gibt an, ob erkannte Punkte wie Nasen, Augen, Ohren, etc. ebenfalls visualisiert werden sollen.
  final bool _showLandmarks;

  /// Gibt an, ob Gesichtskonturen ebenfalls visualisiert werden sollen.
  final bool _showContours;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (_faces.isEmpty) return;

    final FaceGeometryCalculator ft = FaceGeometryCalculator(
        processedSize: _imageSize,
        canvasSize: size,
        isFrontCamera: _isFrontCamera);

    // Debug-Ausgabe:
    //print('FaceMarkingsPainter:');
    //print('Canvas size: $size, Image size: $_imageSize');
    //print('Scale: ${ft.scale}');
    //print(_faces.length);

    for (final Face face in _faces) {
      final faceRect = ft.transformBoundingBox(face.boundingBox);

      final double faceWidthPortion =
          ((faceRect.width < 0) ? -faceRect.width : faceRect.width) /
              ft.canvasWidth;
      final double faceHeightPortion =
          ((faceRect.height < 0) ? -faceRect.height : faceRect.height) /
              ft.canvasHeight;
      // Maximum statt Durchschnitt verwenden, um asymmetrische Schrumpfung an Seitenrand zu verhindern.
      final double facePortion = max(faceHeightPortion, faceWidthPortion);

      if (_showFaceBox) {
        final double faceRectRadius = 70.0 * facePortion;
        final roundedFaceRect = RRect.fromRectAndCorners(faceRect,
            topLeft: Radius.circular(faceRectRadius),
            topRight: Radius.circular(faceRectRadius),
            bottomLeft: Radius.circular(faceRectRadius),
            bottomRight: Radius.circular(faceRectRadius));

        final Paint faceRectPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0 * facePortion
          ..color = Colors.white;
        final Paint faceRectInnerPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * facePortion
          ..color = Colors.blueAccent;

        // Debug-Ausgabe
        //print('Gesichtsbreite: ${faceRect.width}');
        //print('Gesichtshöhe: ${faceRect.height}');
        //print('Gesichtshöhe: ${faceRect.height}');
        //print('Anteil der Gesichtsbreite: $faceWidthPortion');
        //print('Anteil der Gesichtshöhe: $faceHeightPortion');
        //print('Anteil des Gesichts: $facePortion');

        final totalRotation = ft.calculateFaceZRotation(face);

        // Canvas-Transformationen
        canvas.save();

        // Um Mittelpunkt des Gesichts rotieren
        canvas.translate(faceRect.center.dx, faceRect.center.dy);
        canvas.rotate(totalRotation);
        canvas.translate(-faceRect.center.dx, -faceRect.center.dy);

        canvas.drawRRect(roundedFaceRect, faceRectPaint);
        canvas.drawRRect(roundedFaceRect, faceRectInnerPaint);

        canvas.restore();
      }

      // Gesichts-Features:
      if (face.landmarks.isNotEmpty && _showLandmarks) {
        List<Offset> points = [];
        for (final FaceLandmarkType landmarkType in face.landmarks.keys) {
          if (face.landmarks[landmarkType] == null) {
            continue;
          }
          final landmarkOffset =
              ft.transformPoint(face.landmarks[landmarkType]!.position);
          points.add(landmarkOffset);
        }

        final strokeWidth = 4.0 * facePortion;
        final Paint pointPaint = Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = strokeWidth
          ..color = Colors.white.withAlpha(150)
          ..strokeCap = StrokeCap.round;

        canvas.drawPoints(PointMode.points, points, pointPaint);
      }

      if (_showContours && face.contours.isNotEmpty) {
        for (final FaceContourType contourType in face.contours.keys) {
          final faceContour = face.contours[contourType];
          if (faceContour == null) {
            continue;
          }
          final List<Point<int>> contourPoints = faceContour.points;
          final List<Offset> contourOffsets = ft.transformPoints(contourPoints);

          final strokeWidth = 3.0 * facePortion;
          final Paint contourPaint = Paint()
            ..style = PaintingStyle.fill
            ..strokeWidth = strokeWidth
            ..color = standardContourColors[contourType]!.withAlpha(150)
            ..strokeCap = StrokeCap.round;

          canvas.drawPoints(PointMode.points, contourOffsets, contourPaint);

          for (int i = 0; i < contourOffsets.length; i++) {
            final currentOffset = contourOffsets[i];
            final isLastOffset = i + 1 >= contourOffsets.length;
            final nextOffset =
                isLastOffset ? contourOffsets[0] : contourOffsets[i + 1];

            Set<FaceContourType> fullConnectingTypes = <FaceContourType>{
              FaceContourType.face,
              FaceContourType.leftEye,
              FaceContourType.rightEye
            };

            if (isLastOffset && !fullConnectingTypes.contains(contourType)) {
              continue;
            }
            canvas.drawLine(currentOffset, nextOffset, contourPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant final FaceMarkingsPainter oldDelegate) {
    return oldDelegate._faces != _faces;
  }
}
