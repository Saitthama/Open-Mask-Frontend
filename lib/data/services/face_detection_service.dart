import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
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

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

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
      final InputImage? inputImage = _inputImageFromCameraImage(image);

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

  /// https://pub.dev/packages/google_mlkit_commons
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final sensorOrientation = _cameraService.camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[
          _cameraService.cameraController.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (_cameraService.camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _faceDetector.close();
  }
}
