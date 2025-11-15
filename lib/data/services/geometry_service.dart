import 'dart:math';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Utility-Class für geometrische Operationen
class GeometryService {
  /// Rotiert das angegebene Offset [offset] unter Berücksichtigung des Flutter-Koordinatensystems (invertiertes y) um den angegeben Winkel [angle] (Radiant/Bogenmaß).
  static Offset rotateOffset(final Offset offset, final double angle) {
    final rotatedOffsetX = offset.dx * cos(angle) + offset.dy * sin(angle);
    // x′ = x * cos(alpha) − y * sin(alpha)
    // --> sin umdrehen, weil y-Achso im Canvas invertiert ist (von oben nach unten)
    final rotatedOffsetY = offset.dx * sin(angle) + offset.dy * cos(angle);
    // y′ = x * sin(θ) + y * cos(θ)

    return Offset(rotatedOffsetX, rotatedOffsetY);
  }

  /// Berechnet den Mittelpunkt zwischen zwei Punkten.
  static Offset midpoint(final Offset a, final Offset b) =>
      Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

  /// Skaliert einen Offset prozentual (Offset in %) auf eine Breite und Höhe.
  static Offset scaleOffset(
      final Offset offset, final double width, final double height) {
    return Offset(offset.dx / 100 * width, offset.dy / 100 * height);
  }

  /// Wandelt die Rotation eines Gesichts [face] von Grad in Radiant um. Berücksichtigt, wenn nötig, auch zusätzliche Rotation [extraRotation] und Spiegelung ([inverseX] == true).
  static double calculateFaceZRotation(final Face face,
      {final double extraRotation = 0.0, final bool inverseX = false}) {
    final faceRotation =
        (inverseX ? -face.headEulerAngleZ! : face.headEulerAngleZ!) * pi / 180;
    final double extraRotationInRadiant =
        (inverseX ? -extraRotation : extraRotation) * pi / 180;

    final totalRotation = faceRotation + extraRotationInRadiant;
    return totalRotation;
  }
}
