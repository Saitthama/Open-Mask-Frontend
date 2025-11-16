import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/views/filter_view.dart';
import 'package:provider/provider.dart';

import '../views/face_detector_view.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(final BuildContext context) {
    final vm = context.watch<CameraViewModel>();

    if (!vm.initializedAndLive) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: CameraPreview(vm.cameraService.cameraController!),
          ),
          Center(
            child: FaceDetectorView(
                showMarkings: vm.showMarkings, showLandmarks: vm.showLandmarks),
          ),
          if (vm.filter != null) Center(child: FilterView(vm.filter!)),

          // TODO: Buttons hinzufügen
        ],
      ),
    );
  }
}
