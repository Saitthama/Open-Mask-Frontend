import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceMarkingsPainter extends CustomPainter {
  final List<Face> _faces;
  final Size _imageSize;
  final bool isFrontCamera;
  final bool showLandmarks;

  FaceMarkingsPainter(this._faces, this._imageSize,
      {this.isFrontCamera = false, this.showLandmarks = true});

  @override
  void paint(Canvas canvas, Size size) {
    // richtige Zuordnung von Breite und Höhe
    final double canvasWidth = min(size.width, size.height);
    final double canvasHeight = max(size.width, size.height);
    final double originalWidth = min(_imageSize.width, _imageSize.height);
    final double originalHeight = max(_imageSize.width, _imageSize.height);
    // Scale ausrechnen
    final double scaleX = canvasWidth / originalWidth;
    final double scaleY = canvasHeight / originalHeight;

    // Debug-Ausgabe:
    print("FaceMarkingsPainter:");
    print("Canvas size: $size, Image size: $_imageSize");
    print("ScaleX: $scaleX, ScaleY: $scaleY");
    print(_faces.length);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (Face face in _faces) {
      double left = isFrontCamera
          ? size.width - face.boundingBox.left * scaleX // spiegeln
          : face.boundingBox.left * scaleX;
      double top = face.boundingBox.top * scaleY;
      double right = isFrontCamera
          ? size.width - face.boundingBox.right * scaleX // spiegeln
          : face.boundingBox.right * scaleX;
      double bottom = face.boundingBox.bottom * scaleY;

      final rect = Rect.fromLTRB(left, top, right, bottom);

      canvas.drawRect(rect, paint);

      if (!showLandmarks) {
        continue;
      }
      // Gesichts-Features:
      if (face.landmarks.isNotEmpty) {
        Paint pointPaint = Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 2.0
          ..color = Colors.white;

        List<Offset> points = List.from([], growable: true);
        for (FaceLandmarkType landmarkType in face.landmarks.keys) {
          Point<int> landmarkPosition = face.landmarks[landmarkType]!.position;
          double x = isFrontCamera
              ? size.width - landmarkPosition.x.toDouble() * scaleX // spiegeln
              : landmarkPosition.x.toDouble() * scaleX;
          double y = landmarkPosition.y.toDouble() * scaleY;

          Offset offset = Offset(x, y);
          points.add(offset);
        }
        canvas.drawPoints(PointMode.points, points, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FaceMarkingsPainter oldDelegate) {
    return oldDelegate._faces != _faces;
  }
}
