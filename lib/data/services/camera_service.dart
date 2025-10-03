import 'dart:io';

import 'package:camera/camera.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

class CameraService {
  late CameraController cameraController;
  late CameraDescription camera;
  final ResolutionPreset resolutionPreset;

  CameraService({this.resolutionPreset = ResolutionPreset.medium});

  Future<void> initialize() async {
    final cameras = await availableCameras();
    // Bevorzugt die Frontkamera wählen:
    camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // Kamera Controller initialisieren:
    cameraController = CameraController(
      camera, resolutionPreset,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup
              .nv21 // Format, das für Android verwendet werden soll
          : ImageFormatGroup
              .bgra8888, // Format, das für iOS verwendet werden soll
    );
    await cameraController.initialize();
  }

  Future<XFile> takePicture() async {
    if (!cameraController.value.isInitialized) {
      SnackBarService.showMessage("Kamera noch nicht initialisiert");
    }
    return await cameraController.takePicture();
  }

  void dispose() {
    cameraController.dispose();
  }
}
