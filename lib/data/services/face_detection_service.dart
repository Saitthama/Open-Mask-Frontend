import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

import 'camera_service.dart';

class FaceDetectionService extends ChangeNotifier {
  bool _isDetecting = false;
  List<Face> _faces = [];
  late Size _imageSize;
  late FaceDetector _faceDetector;
  final CameraService _cameraService;

  List<Face> get faces => _faces;

  Size get imageSize => _imageSize;

  FaceDetector get faceDetector => _faceDetector;

  CameraService get cameraService => _cameraService;

  FaceDetectionService(this._cameraService);

  // aktualisiert Variablen und benachrichtigt Beobachter
  void _update(List<Face> newFaces, Size newImageSize) {
    _faces = newFaces;
    _imageSize = newImageSize;
    notifyListeners();
  }

  // Optionen für den Face Detector
  final _faceDetectorOptions = FaceDetectorOptions(
    enableContours: true, // Aktiviert zusätzliche Kontur-Informationen
    enableLandmarks: true, // Aktiviert die Erkennung von Augen, Nase, Mund usw.
    enableClassification:
        true, // zusätzliche Klassifikationen: z.B. Lächeln, Augen offen
  );

  Future<void> initialize() async {
    // FaceDetector initialisieren:
    _faceDetector = FaceDetector(options: _faceDetectorOptions);
    // Vorübergehend, damit es einen Wert hat. Bekommt später die Originalgröße
    _imageSize = _cameraService.cameraController.value.previewSize!;

    await _cameraService.cameraController.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      _isDetecting = true;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      // CameraImage in InputImage umwandeln:
      final InputImage? inputImage = ImageService.inputImageFromCameraImage(
          image, _cameraService.camera, _cameraService.cameraController);

      if (inputImage == null) {
        SnackBarService.showMessage(
            "Fehler bei der Umwandlung des Bildformates (${InputImageFormatValue.fromRawValue(image.format.raw)})");
        return;
      }

      // Originalgröße zuweisen
      Size newImageSize = inputImage.metadata!.size;

      // Bild mit dem FaceDetector verarbeiten:
      final List<Face> detectedFaces =
          await _faceDetector.processImage(inputImage);

      _update(detectedFaces, newImageSize);
    } catch (e) {
      SnackBarService.showMessage("Fehler bei der Verarbeitung des Bildes: $e");
    } finally {
      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _faceDetector.close();
  }
}
