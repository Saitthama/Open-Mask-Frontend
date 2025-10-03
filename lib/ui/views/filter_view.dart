import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:provider/provider.dart';

import '../../filter/face_filter_painter.dart';
import '../../filter/i_filter.dart';

class FilterView extends StatelessWidget {
  final IFilter _filter;

  const FilterView(this._filter, {super.key});

  @override
  Widget build(BuildContext context) {
    final faceDetectionService = Provider.of<FaceDetectionService>(context);
    final cameraService = Provider.of<CameraService>(context);
    return CustomPaint(
      foregroundPainter: FaceFilterPainter(
        faces: faceDetectionService.faces,
        imageSize: faceDetectionService.imageSize,
        isFrontCamera:
            cameraService.cameraController.description.lensDirection ==
                CameraLensDirection.front,
        filter: _filter,
      ),
      size: cameraService.cameraController.value.previewSize!,
    );
  }
}
