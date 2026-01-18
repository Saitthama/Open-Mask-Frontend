import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:provider/provider.dart';

import '../../filter/i_filter.dart';
import '../painter/face_filter_painter.dart';

/// View, welches ein Filter-Overlay über darstellt, welches Filter mithilfe vom [FaceFilterPainter] darstellt.
class FilterView extends StatelessWidget {
  /// Standard-Konstruktor. <br>
  /// [_filter] ist der Filter, der gerade verwendet wird.
  const FilterView(this._filter, {super.key});

  /// Filter, der gerade verwendet wird.
  final IFilter _filter;

  @override
  Widget build(final BuildContext context) {
    final faceDetectionService = Provider.of<FaceDetectionService>(context);
    final cameraService = Provider.of<CameraService>(context);
    if (faceDetectionService.processedSize == null) {
      return Container();
    }
    return CustomPaint(
      foregroundPainter: FaceFilterPainter(
        faces: faceDetectionService.faces,
        imageSize: faceDetectionService.processedSize!,
        isFrontCamera:
            cameraService.cameraController?.description.lensDirection ==
                CameraLensDirection.front,
        filter: _filter,
      ),
      size: Size.infinite,
    );
  }
}
