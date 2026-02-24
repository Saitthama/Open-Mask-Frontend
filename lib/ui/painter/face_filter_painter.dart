import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';

/// Ein [CustomPainter], welcher dazu dient einen Filter auf mehrere Gesichter anzuwenden.
class FaceFilterPainter extends CustomPainter {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>[faces] Liste der Gesichter, auf die der Filter angewandt werden soll.</li>
  ///   <li>[processedSize] Originalgröße des analysierten Bildes.</li>
  ///   <li>[isFrontCamera] Gibt an, ob die verwendete Kamera die Frontkamera ist und der Filter daher gespiegelt werden muss.</li>
  ///   <li>[filter] Der Filter, der angewandt werden soll.</li>
  /// </ul>
  FaceFilterPainter({
    required this.faces,
    required this.processedSize,
    required this.isFrontCamera,
    required this.filter,
  });

  /// Gesichter, auf die der angegebene Filter [filter] angewendet werden soll.
  final List<Face> faces;

  /// Größe des von ML Kit analysierten Bildes.
  final Size processedSize;

  /// Gibt an, ob die verwendete Kamera die Frontkamera ist und das Preview daher gespiegelt ist.
  final bool isFrontCamera;

  /// Der Filter, der auf die Gesichter [faces] angewendet werden soll.
  final IFilter filter;

  /// Malt den Filter auf das angegebene [image] und liefert ein neues Bild mit angewandtem Filter als [ui.Image] zurück.
  Future<ui.Image> paintOnImage(final ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);

    this.paint(canvas, processedSize);

    final picture = recorder.endRecording();
    final editedImage = await picture.toImage(image.width, image.height);
    return editedImage;
  }

  @override
  void paint(final Canvas canvas, final Size size) {
    FaceGeometryCalculator faceGeometryCalculator = FaceGeometryCalculator(
        processedSize: processedSize,
        canvasSize: size,
        isFrontCamera: isFrontCamera);

    for (final Face face in faces) {
      filter.apply(face, canvas, faceGeometryCalculator);
    }
  }

  @override
  bool shouldRepaint(covariant final FaceFilterPainter oldDelegate) {
    if (oldDelegate.filter is CompositeFilter && filter is CompositeFilter) {
      return true; // Damit Filter direkt hinzugefügt werden
    }

    return oldDelegate.faces != faces || oldDelegate.filter != filter;
  }
}
