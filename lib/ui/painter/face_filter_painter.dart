import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/i_filter.dart';

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
    required final List<Face> faces,
    required final Size processedSize,
    required final bool isFrontCamera,
    required final IFilter filter,
  })  : _processedSize = processedSize,
        _faces = faces,
        _isFrontCamera = isFrontCamera,
        _filter = filter;

  /// Gesichter, auf die der angegebene Filter [_filter] angewendet werden soll.
  final List<Face> _faces;

  /// Größe des von ML Kit analysierten Bildes.
  final Size _processedSize;

  /// Gibt an, ob die verwendete Kamera die Frontkamera ist und das Preview daher gespiegelt ist.
  final bool _isFrontCamera;

  /// Der Filter, der auf die Gesichter [_faces] angewendet werden soll.
  final IFilter _filter;

  /// Malt den Filter auf das angegebene [image] und liefert ein neues Bild mit angewandtem Filter als [ui.Image] zurück.
  Future<ui.Image> paintOnImage(final ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);

    this.paint(canvas, _processedSize);

    final picture = recorder.endRecording();
    final editedImage = await picture.toImage(image.width, image.height);
    return editedImage;
  }

  @override
  void paint(final Canvas canvas, final Size size) {
    FaceGeometryCalculator faceGeometryCalculator = FaceGeometryCalculator(
        processedSize: _processedSize,
        canvasSize: size,
        isFrontCamera: _isFrontCamera);

    for (final Face face in _faces) {
      _filter.apply(face, canvas, faceGeometryCalculator);
    }
  }

  @override
  bool shouldRepaint(covariant final FaceFilterPainter oldDelegate) {
    return oldDelegate._faces != _faces || oldDelegate._filter != _filter;
  }
}
