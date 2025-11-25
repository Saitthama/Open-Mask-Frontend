import 'dart:math';
import 'dart:ui';

/// Utility-Class für geometrische Operationen
class GeometryService {
  /// Rotiert das angegebene Offset [offset] unter Berücksichtigung des Flutter-Koordinatensystems (invertiertes y) um den angegeben Winkel [angle] (Radiant/Bogenmaß).
  static Offset rotateOffset(final Offset offset, final double angle) {
    final x = offset.dx * cos(angle) - offset.dy * sin(angle);
    // x′ = x * cos(alpha) − y * sin(alpha)
    // --> normalerweise müsste man sin umdrehen, weil y-Achse im Canvas invertiert ist (von oben nach unten),
    // aber ML-Kit verwendet auch so ein Koordinatensystem

    final y = offset.dx * sin(angle) + offset.dy * cos(angle);
    // y′ = x * sin(θ) + y * cos(θ)

    //print('rotateOffset($offset, $angle) => Offset($x, $y)');
    return Offset(x, y);
  }

  /// Berechnet den Mittelpunkt zwischen den zwei angegebnen Punkten [a] & [b].
  static Offset midpoint(final Offset a, final Offset b) =>
      Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

  /// Skaliert ein Offset ([offset] in % angegeben) prozentual auf eine Breite ([width]) und Höhe ([height]).
  static Offset scaleOffset(
      final Offset offset, final double width, final double height) {
    return Offset(offset.dx / 100 * width, offset.dy / 100 * height);
  }
}
