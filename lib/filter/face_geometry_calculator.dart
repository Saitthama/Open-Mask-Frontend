import 'dart:math';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Hilfsklasse zur Berechnung von geometrischen Operationen für Canvas-Operationen mit Gesichtern.
class FaceGeometryCalculator {
  /// Standard-Konstruktor. Berechnet die [canvasWidth], [canvasHeight], [scaleX] und [scaleY] aus den angegebenen Attributen.
  /// <ul>
  ///   <li>Die [imageSize] stellt die Bildgröße des Originalbildes dar, das von ML-Kit verarbeitet/analysiert wurde.</li>
  ///   <li>Die [canvasSize] stellt die Größe des Canvas/Previews dar.</li>
  ///   <li>Der Parameter [isFrontCamera] gibt an, ob die Frontkamera verwendet wird, damit folglich Spiegelung bei den Operationen angewandt wird.</li>
  /// </ul>
  FaceGeometryCalculator({
    required this.imageSize,
    required this.canvasSize,
    required this.isFrontCamera,
  }) {
    canvasWidth = canvasSize.width;
    canvasHeight = canvasSize.height;

    scaleX = canvasWidth / imageSize.width;
    scaleY = canvasHeight / imageSize.height;
    //print('create FaceCoordinateTransformer: ');
    //print('- imageSize: $imageSize');
    //print('- canvasSize: $canvasSize');
    //print('- isFrontCamera: $isFrontCamera');
    //print('- scaleX: $scaleX');
    //print('- scaleY: $scaleY');
  }

  /// Bildgröße des Originalbildes, das von ML-Kit verarbeitet/analysiert wurde.
  final Size imageSize;

  /// Größe des Canvas/Previews.
  final Size canvasSize;

  /// Gibt an, ob die Frontkamera verwendet wird, damit folglich Spiegelung bei den Operationen angewandt wird.
  final bool isFrontCamera;

  /// Skalierung von der originalen Breite (siehe [imageSize]) zur Preview/Canvas-Breite (siehe [canvasSize]).
  late double scaleX;

  /// Skalierung von der originalen Höhe (siehe [imageSize]) zur Preview/Canvas-Höhe (siehe [canvasSize]).
  late double scaleY;

  /// Die Breite des Canvas (übernommen von der [canvasSize]).
  late double canvasWidth;

  /// Die Höhe des Canvas (übernommen von der [canvasSize]).
  late double canvasHeight;

  /// Transformiert den angegebennen [point] unter Berücksichtigung von Skalierung und eventuell Spiegelung. <br>
  /// Liefert ein [Offset] zurück.
  Offset transformPoint(final Point<int> point) {
    double x = point.x * scaleX;
    double y = point.y * scaleY;

    if (isFrontCamera) {
      x = canvasWidth - x;
    }
    //print('transformPoint($point) => ($x|$y)');
    return Offset(x, y);
  }

  /// Transformiert das angegebene [offset] passend zur Skalierung ([scaleX]|[scaleY]) und eventueller Spiegelung ([isFrontCamera]).
  Offset transformOffset(final Offset offset) {
    final scaledX = offset.dx * scaleX;
    final scaledY = offset.dy * scaleY;
    final transformedOffset =
        Offset(isFrontCamera ? canvasWidth - scaledX : scaledX, scaledY);
    //print('transformOffset($offset) => $transformedOffset');
    return transformedOffset;
  }

  /// Transformiert das angegebene [rect].
  Rect transformBoundingBox(final Rect rect) {
    double left = rect.left * scaleX;
    double top = rect.top * scaleY;
    double width = rect.width * scaleX;
    double height = rect.height * scaleY;

    if (isFrontCamera) {
      left = canvasWidth - left - width;
    }
    final transformedRect = Rect.fromLTWH(left, top, width, height);
    //print('transformBoundingBox($rect) => $transformedRect');
    return transformedRect;
  }

  /// Wandelt die Rotation eines Gesichts [face] von Grad in Radiant um. Berücksichtigt auch eine mögliche zusätzliche Rotation [extraRotation] (in Grad) und Spiegelung.
  double calculateFaceZRotation(final Face face,
      {final double extraRotation = 0.0}) {
    // MLKit: gegen den Uhrzeigersinn = positiv --> Canvas: im Uhrzeigersinn = negativ
    final faceRotation =
        (!isFrontCamera ? -face.headEulerAngleZ! : face.headEulerAngleZ!) *
            pi /
            180;
    final double extraRotationInRadiant =
        (!isFrontCamera ? -extraRotation : extraRotation) * pi / 180;

    final totalRotation = faceRotation + extraRotationInRadiant;
    //print('calculateFaceZRotation(headEulerAngleZ: ${face.headEulerAngleZ}, $extraRotation) => $totalRotation');
    return totalRotation;
  }
}
