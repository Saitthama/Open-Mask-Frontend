import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../filter/i_filter.dart';
import '../painter/face_filter_painter.dart';

/// View, welches ein Filter-Overlay über darstellt, welches Filter mithilfe vom [FaceFilterPainter] darstellt.
class FilterView extends StatelessWidget {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>[filter] ist der Filter, der angewandt werden soll.</li>
  ///   <li>[faces] enthält die Gesichter, auf die der Filter angewandt werden soll.</li>
  ///   <li>[processedSize] ist die Originalgröße des verarbeiteten Bildes.</li>
  ///   <li>[isFrontCamera] gibt an, ob die verwendete Kamera die Frontkamera ist und der Filter daher gespiegelt werden muss.</li>
  /// </ul>
  const FilterView(this.filter,
      {super.key,
      required this.faces,
      this.processedSize,
      required this.isFrontCamera});

  /// Filter, der gerade verwendet wird.
  final IFilter filter;

  /// Gesichter, auf die der angegebene Filter [filter] angewendet werden soll.
  final List<Face> faces;

  /// Größe des von ML Kit analysierten Bildes.
  final Size? processedSize;

  /// Gibt an, ob die verwendete Kamera die Frontkamera ist und das Preview daher gespiegelt ist.
  final bool isFrontCamera;

  @override
  Widget build(final BuildContext context) {
    if (processedSize == null) {
      return Container();
    }
    return CustomPaint(
      foregroundPainter: FaceFilterPainter(
        faces: faces,
        processedSize: processedSize!,
        isFrontCamera: isFrontCamera,
        filter: filter,
      ),
      size: Size.infinite,
    );
  }
}
