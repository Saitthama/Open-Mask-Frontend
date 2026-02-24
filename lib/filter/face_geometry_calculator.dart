import 'dart:math';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/geometry_service.dart';

/// Hilfsklasse zur Berechnung von geometrischen Operationen für Canvas-Operationen mit Gesichtern.
class FaceGeometryCalculator {
  /// Standard-Konstruktor. Berechnet die [canvasWidth], [canvasHeight], [scaleX] und [scaleY] aus den angegebenen Attributen.
  /// <ul>
  ///   <li>Die [processedSize] stellt die Bildgröße des von ML-Kit verarbeiteten/analysierten Bildes.</li>
  ///   <li>Die [canvasSize] stellt die Größe des Canvas/Previews dar.</li>
  ///   <li>Der Parameter [isFrontCamera] gibt an, ob die Frontkamera verwendet wird, damit folglich Spiegelung bei den Operationen angewandt wird.</li>
  /// </ul>
  FaceGeometryCalculator({
    required this.processedSize,
    required this.canvasSize,
    required this.isFrontCamera,
  }) {
    canvasWidth = canvasSize.width;
    canvasHeight = canvasSize.height;

    final imageAspect = processedSize.width / processedSize.height;
    final canvasAspect = canvasWidth / canvasHeight;

    if (canvasAspect > imageAspect) {
      // Canvas ist breiter --> Höhe passt
      scale = canvasWidth / processedSize.width;
      final scaledHeight = processedSize.height * scale;
      dx = 0;
      dy = (canvasHeight - scaledHeight) / 2;
    } else {
      // Canvas ist höher --> Breite passt
      scale = canvasHeight / processedSize.height;
      final scaledWidth = processedSize.width * scale;
      dx = (canvasWidth - scaledWidth) / 2;
      dy = 0;
    }
  }

  /// Bildgröße des von ML-Kit verarbeiteten/analysierten Bildes.
  final Size processedSize;

  /// Größe des Canvas/Previews.
  final Size canvasSize;

  /// Gibt an, ob die Frontkamera verwendet wird, damit folglich Spiegelung bei den Operationen angewandt wird.
  final bool isFrontCamera;

  /// Skalierung von der originalen Größe ([processedSize]) zur Preview/Canvas-Größe ([canvasSize]).
  late final double scale;

  late final double dx;

  late final double dy;

  /// Die Breite des Canvas (übernommen von der [canvasSize]).
  late final double canvasWidth;

  /// Die Höhe des Canvas (übernommen von der [canvasSize]).
  late final double canvasHeight;

  /// Transformiert den angegebenen [point] unter Berücksichtigung von Skalierung und eventuell Spiegelung. <br>
  /// Liefert ein [Offset] zurück.
  Offset transformPoint(final Point<int> point) {
    double x = point.x * scale + dx;
    double y = point.y * scale + dy;

    if (isFrontCamera) {
      x = canvasWidth - x;
    }
    //print('transformPoint($point) => ($x|$y)');
    return Offset(x, y);
  }

  /// Transformiert die angegeben [points] unter Berücksichtigung von Skalierung und eventuell Spiegelung. <br>
  /// Liefert eine Liste der transformierten Punkte (als [Offset]) zurück.
  List<Offset> transformPoints(final List<Point<int>> points) {
    List<Offset> pointsAsOffsets = [];
    for (final Point<int> point in points) {
      pointsAsOffsets.add(transformPoint(point));
    }
    return pointsAsOffsets;
  }

  /// Transformiert das angegebene [offset] passend zur Skalierung ([scaleX]|[scaleY]) und eventueller Spiegelung ([isFrontCamera]).
  Offset transformOffset(final Offset offset) {
    final scaledX = offset.dx * scale + dx;
    final scaledY = offset.dy * scale + dy;
    final transformedOffset =
        Offset(isFrontCamera ? canvasWidth - scaledX : scaledX, scaledY);
    //print('transformOffset($offset) => $transformedOffset');
    return transformedOffset;
  }

  /// Transformiert das angegebene [rect].
  Rect transformBoundingBox(final Rect rect) {
    double left = rect.left * scale + dx;
    double top = rect.top * scale + dy;
    double width = rect.width * scale + dx;
    double height = rect.height * scale + dy;

    if (isFrontCamera) {
      left = canvasWidth - left - width;
    }
    final transformedRect = Rect.fromLTWH(left, top, width, height);
    //print('transformBoundingBox($rect) => $transformedRect');
    return transformedRect;
  }

  /// Berechnet die Gesichtsgröße dynamisch, bevorzugt über Landmarken, oder alternativ über die Gesichtsbox.
  Size calculateDynamicFaceSize(final Face face) {
    final landmarks = face.landmarks;
    late final double faceWidth;
    late final double faceHeight;

    final leftEye = landmarks[FaceLandmarkType.leftEye];
    final rightEye = landmarks[FaceLandmarkType.rightEye];
    final noseBase = landmarks[FaceLandmarkType.noseBase];

    final faceBox = transformBoundingBox(face.boundingBox);

    if (leftEye == null || rightEye == null || noseBase == null) {
      faceWidth = faceBox.width;
      faceHeight = faceBox.height;
    } else {
      final leftEyePosition = transformPoint(leftEye.position);
      final rightEyePosition = transformPoint(rightEye.position);

      final eyeDistance = (leftEyePosition - rightEyePosition).distance;
      faceWidth = eyeDistance * 3;
      faceHeight = eyeDistance * 3;
      //print('Eye Distance: $eyeDistance');
      //print('Face-Box: $faceBox');
    }

    return Size(faceWidth, faceHeight);
  }

  /// Berechnet die Gesichtsmitte dynamisch, bevorzugt über Landmarken, oder alternativ über die Gesichtsbox.
  Offset calculateDynamicFaceCenter(final Face face) {
    final landmarks = face.landmarks;
    late final Offset faceCenter;

    final leftEye = landmarks[FaceLandmarkType.leftEye];
    final rightEye = landmarks[FaceLandmarkType.rightEye];
    final noseBase = landmarks[FaceLandmarkType.noseBase];

    final faceBox = transformBoundingBox(face.boundingBox);

    if (leftEye == null || rightEye == null || noseBase == null) {
      faceCenter = faceBox.center;
    } else {
      // Gesichtsmitte aus Landmarken berechnen
      final leftEyePosition = transformPoint(leftEye.position);
      final rightEyePosition = transformPoint(rightEye.position);
      final eyeCenter =
          GeometryService.midpoint(leftEyePosition, rightEyePosition);

      // Gesichtszentrum und Breite/Höhe bestimmen
      final noseBasePosition = transformPoint(noseBase.position);
      faceCenter = GeometryService.midpoint(eyeCenter, noseBasePosition);
    }

    return faceCenter;
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
