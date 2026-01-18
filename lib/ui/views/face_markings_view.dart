import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:provider/provider.dart';

import '../painter/face_markings_painter.dart';

/// View, welches ein Filter-Overlay über darstellt, welches Gesichtserkennungsmarkierungen mithilfe vom [FaceMarkingsPainter] darstellt.
class FaceMarkingsView extends StatelessWidget {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>[showMarkings] Gibt an, ob Markierungen angezeigt werden sollen. </li>
  ///   <li>[showFaceBox] gibt an, ob Markierungen angezeigt werden sollen. </li>
  ///   <li>[showLandmarks] Gibt an, ob erkannte Punkte wie Nasen, Augen, Ohren, etc. ebenfalls visualisiert werden sollen. </li>
  ///   <li>[showContours] gibt an, ob Gesichtskonturen ebenfalls visualisiert werden sollen. </li>
  /// </ul>
  const FaceMarkingsView({
    super.key,
    final bool showMarkings = true,
    final bool showFaceBox = true,
    final bool showLandmarks = true,
    final bool showContours = false,
  })  : _showMarkings = showMarkings,
        _showFaceBox = showFaceBox,
        _showLandmarks = showLandmarks,
        _showContours = showContours;

  /// Gibt an, ob Markierungen angezeigt werden sollen.
  final bool _showMarkings;

  /// Gibt an, ob die Gesichtsbox angezeigt werden soll.
  final bool _showFaceBox;

  /// Gibt an, ob erkannte Punkte wie Nasen, Augen, Ohren, etc. ebenfalls visualisiert werden sollen.
  final bool _showLandmarks;

  /// Gibt an, ob Gesichtskonturen ebenfalls visualisiert werden sollen.
  final bool _showContours;

  @override
  Widget build(final BuildContext context) {
    final faceDetectionService = Provider.of<FaceDetectionService>(context);
    final cameraService = Provider.of<CameraService>(context);

    if (!_showMarkings || faceDetectionService.processedSize == null) {
      return Container();
    }

    return CustomPaint(
      foregroundPainter: FaceMarkingsPainter(
          faceDetectionService.faces, faceDetectionService.processedSize!,
          isFrontCamera:
              cameraService.cameraController?.description.lensDirection ==
                  CameraLensDirection.front,
          showFaceBox: _showFaceBox,
          showLandmarks: _showLandmarks,
          showContours: _showContours),
      size: Size.infinite,
    );
  }
}
