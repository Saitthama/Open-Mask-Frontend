import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../painter/face_markings_painter.dart';

/// View, welches ein Filter-Overlay über darstellt, welches Gesichtserkennungsmarkierungen mithilfe vom [FaceMarkingsPainter] darstellt.
class FaceMarkingsView extends StatelessWidget {
  /// Standard-Konstruktor.
  /// <ul>
  ///
  ///   <li>[faces] enthält die Gesichter, auf die der Filter angewandt werden soll.</li>
  ///   <li>[processedSize] ist die Originalgröße des verarbeiteten Bildes.</li>
  ///   <li>[isFrontCamera] gibt an, ob die verwendete Kamera die Frontkamera ist und der Filter daher gespiegelt werden muss.</li>
  ///   <li>[showMarkings] Gibt an, ob Markierungen angezeigt werden sollen. </li>
  ///   <li>[showFaceBox] gibt an, ob Markierungen angezeigt werden sollen. </li>
  ///   <li>[showLandmarks] Gibt an, ob erkannte Punkte wie Nasen, Augen, Ohren, etc. ebenfalls visualisiert werden sollen. </li>
  ///   <li>[showContours] gibt an, ob Gesichtskonturen ebenfalls visualisiert werden sollen. </li>
  /// </ul>
  const FaceMarkingsView({
    super.key,
    required this.faces,
    this.processedSize,
    required this.isFrontCamera,
    this.showMarkings = true,
    this.showFaceBox = true,
    this.showLandmarks = true,
    this.showContours = false,
  });

  /// Gibt an, ob Markierungen angezeigt werden sollen.
  final bool showMarkings;

  /// Gibt an, ob die Gesichtsbox angezeigt werden soll.
  final bool showFaceBox;

  /// Gibt an, ob erkannte Punkte wie Nasen, Augen, Ohren, etc. ebenfalls visualisiert werden sollen.
  final bool showLandmarks;

  /// Gibt an, ob Gesichtskonturen ebenfalls visualisiert werden sollen.
  final bool showContours;

  /// Gesichter, auf die der angegebene Filter [filter] angewendet werden soll.
  final List<Face> faces;

  /// Größe des von ML Kit analysierten Bildes.
  final Size? processedSize;

  /// Gibt an, ob die verwendete Kamera die Frontkamera ist und das Preview daher gespiegelt ist.
  final bool isFrontCamera;

  @override
  Widget build(final BuildContext context) {
    if (!showMarkings || processedSize == null) {
      return Container();
    }

    return CustomPaint(
      foregroundPainter: FaceMarkingsPainter(faces, processedSize!,
          isFrontCamera: isFrontCamera,
          showFaceBox: showFaceBox,
          showLandmarks: showLandmarks,
          showContours: showContours),
      size: Size.infinite,
    );
  }
}
