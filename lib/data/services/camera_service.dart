import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

/// Service zur Verwaltung der Kamerafunktionen.
class CameraService {
  CameraService(
      {this.resolutionPreset = ResolutionPreset.medium,
      final CameraLensDirection cameraLensDirection =
          CameraLensDirection.front})
      : _cameraLensDirection = cameraLensDirection;

  CameraController? cameraController;
  int _cameraIndex = -1;
  List<CameraDescription> _cameras = [];

  // TODO: über Einstellungen setzen
  ResolutionPreset resolutionPreset;
  Function(InputImage inputImage)? onImage;

  // TODO: Kamera wechseln
  CameraLensDirection _cameraLensDirection;

  bool _cameraLive = false;

  bool get cameraLive => _cameraLive;

  CameraLensDirection get cameraLensDirection => _cameraLensDirection;

  CameraDescription? get camera =>
      (_cameras.isEmpty || _cameraIndex == -1) ? null : _cameras[_cameraIndex];

  /// Findet eine passende Kamera und startet sie mit [startCamera].
  Future<void> initialize() async {
    if (_cameras.isEmpty) {
      try {
        _cameras = await availableCameras();
      } catch (e) {
        SnackBarService.showMessage('Probleme beim Finden einer Kamera');
        return;
      }
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == _cameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      await startCamera();
    } else {
      SnackBarService.showMessage('Keine passende Kamera gefunden');
    }
  }

  /// Startet die Kamera und den Bild-Stream an [onImage].
  Future<void> startCamera() async {
    if (camera == null) {
      return;
    }
    // Kamera Controller initialisieren:
    cameraController = CameraController(
      camera!, resolutionPreset,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup
              .nv21 // Format, das für Android verwendet werden soll
          : ImageFormatGroup
              .bgra8888, // Format, das für iOS verwendet werden soll
    );
    try {
      await cameraController!.initialize();
    } catch (e) {
      SnackBarService.showMessage('Initialisierung der Kamera fehlgeschlagen');
      return;
    }
    cameraController?.startImageStream(_processCameraImage);
    _cameraLive = true;
  }

  /// Bild umwandeln und [onImage] zur Verarbeitung aufrufen.
  void _processCameraImage(final CameraImage image) {
    if (onImage == null) return;
    // CameraImage in InputImage umwandeln:
    final inputImage = ImageService.inputImageFromCameraImage(
        image, camera!, cameraController);
    if (inputImage == null) {
      SnackBarService.showMessage(
          'Fehler bei der Umwandlung des Bildformates (${InputImageFormatValue.fromRawValue(image.format.raw)})');
      return;
    }
    onImage!(inputImage);
  }

  Future<XFile> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      SnackBarService.showMessage('Kamera noch nicht initialisiert');
    }
    return await cameraController!.takePicture();
  }

  Future<void> stopCamera() async {
    _cameraLive = false;
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
    cameraController = null;
  }
}
