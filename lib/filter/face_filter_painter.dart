import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/i_filter.dart';

/// Ein [CustomPainter], welcher dazu dient einen Filter auf mehrere Gesichter anzuwenden.
class FaceFilterPainter extends CustomPainter {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>[faces] Liste der Gesichter, auf die der Filter angewandt werden soll.</li>
  ///   <li>[imageSize] Originalgröße des Bildes.</li>
  ///   <li>[isFrontCamera] Gibt an, ob die verwendete Kamera die Frontkamera ist und das Preview daher gespiegelt ist.</li>
  ///   <li>[filter] Der Filter, der angewandt werden soll.</li>
  /// </ul>
  FaceFilterPainter({
    required final List<Face> faces,
    required final Size imageSize,
    required final bool isFrontCamera,
    required final IFilter filter,
  })  : _imageSize = imageSize,
        _faces = faces,
        _isFrontCamera = isFrontCamera,
        _filter = filter;

  /// Gesichter, auf die der angegebene Filter [_filter] angewendet werden soll.
  final List<Face> _faces;

  /// Größe des aufgenommenen und analysierten Bildes.
  final Size _imageSize;

  /// Gibt an, ob die verwendete Kamera die Frontkamera ist und das Preview daher gespiegelt ist.
  final bool _isFrontCamera;

  /// Der Filter, der auf die Gesichter [_faces] angewendet werden soll.
  final IFilter _filter;

  @override
  void paint(final Canvas canvas, final Size size) {
    FaceGeometryCalculator faceCoordinateTransformer = FaceGeometryCalculator(
        imageSize: _imageSize, canvasSize: size, isFrontCamera: _isFrontCamera);

    for (final Face face in _faces) {
      _filter.apply(face, canvas, faceCoordinateTransformer);
    }
  }

  @override
  bool shouldRepaint(covariant final FaceFilterPainter oldDelegate) {
    return oldDelegate._faces != _faces || oldDelegate._filter != _filter;
  }
}
