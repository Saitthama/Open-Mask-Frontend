import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:provider/provider.dart';

import 'face_markings_painter.dart';

class FaceMarkingsView extends StatelessWidget {
  const FaceMarkingsView(
      {super.key,
      final bool showMarkings = true,
      final bool showLandmarks = true})
      : _showLandmarks = showLandmarks,
        _showMarkings = showMarkings;

  final bool _showMarkings;
  final bool _showLandmarks;

  @override
  Widget build(final BuildContext context) {
    final faceDetectionService = Provider.of<FaceDetectionService>(context);
    final cameraService = Provider.of<CameraService>(context);

    if (!_showMarkings || faceDetectionService.imageSize == null) {
      return Container();
    }

    print('Face Detector View build');
    return CustomPaint(
      foregroundPainter: FaceMarkingsPainter(
          faceDetectionService.faces, faceDetectionService.imageSize!,
          isFrontCamera:
              cameraService.cameraController?.description.lensDirection ==
                  CameraLensDirection.front,
          showLandmarks: _showLandmarks),
      size: (cameraService.cameraController?.value.previewSize != null)
          ? cameraService.cameraController!.value.previewSize!
          : Size.zero,
    );
  }
}
