import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:synchronized/synchronized.dart';

/// Service zur Verwaltung der Kamerafunktionen.
class CameraService {
  /// Standard-Konstruktor.
  CameraService(
      {this.resolutionPreset = ResolutionPreset.medium,
      final CameraLensDirection initialCameraLensDirection =
          CameraLensDirection.front})
      : _initialCameraLensDirection = initialCameraLensDirection;

  /// Controller, der auf die Kamera zugreift und über den diese gesteuert werden kann.
  CameraController? cameraController;

  /// Lock-Objekt, mit dem Veränderungen am Controller synchronisiert werden können,
  /// um Race Conditions zu vermeiden.
  final controllerLock = Lock();

  /// Index der aktuell ausgewählten Kamera für die [_cameras]-Liste.
  int _cameraIndex = -1;

  /// Liste aller verfügbaren Kameras. Wird in [initialize] geladen.
  List<CameraDescription> _cameras = [];

  // TODO: über Einstellungen setzen
  /// Gibt die Kameraauflösung an.
  ResolutionPreset resolutionPreset;

  /// Funktion, an die die Bilder der Kamera als InputImage gestreamt werden.
  Function(InputImage inputImage, int rotationDegrees)? onImageToProcess;

  /// Gibt die initiale Ausrichtung an.
  final CameraLensDirection _initialCameraLensDirection;

  /// Gibt an, ob die Kamera läuft und an [onImageToProcess] streamt.
  bool _cameraLive = false;

  /// Gibt an, ob die Kamera läuft und an [onImageToProcess] streamt.
  bool get cameraLive => _cameraLive;

  /// Gibt die aktuelle Kameraausrichtung oder, falls keine Kamera gefunden wird, die initiale Ausrichtung an.
  CameraLensDirection get cameraLensDirection =>
      (camera != null) ? camera!.lensDirection : _initialCameraLensDirection;

  /// Aktuell ausgewählte Kamera.
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
      if (_cameras[i].lensDirection == _initialCameraLensDirection) {
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

  /// Startet die Kamera und den Bild-Stream an [onImageToProcess].
  Future<void> startCamera() async {
    if (camera == null) {
      return;
    }
    await controllerLock.synchronized(() async {
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
        SnackBarService.showMessage(
            'Initialisierung der Kamera fehlgeschlagen!');
        return;
      }
      try {
        cameraController?.startImageStream(_processCameraImage);
      } catch (e) {
        SnackBarService.showMessage('Starten des Bild-Streams fehlgeschlagen!');
      }
      if (cameraController == null || !cameraController!.value.isInitialized) {
        SnackBarService.showMessage('Starten der Kamera fehlgeschlagen!');
        return;
      }
      _cameraLive = true;
    });
  }

  /// Stoppt die Kamera und den Bild-Stream an [onImageToProcess].
  Future<void> stopCamera() async {
    await controllerLock.synchronized(() async {
      _cameraLive = false;
      await cameraController?.stopImageStream();
      await cameraController?.dispose();
      cameraController = null;
    });
  }

  /// Nimmt ein Bild auf und speichert es in der App-Galerie über das [ImageService]. <br>
  /// Liefert null zurück, falls die Kamera noch nicht initialisiert wurde.
  Future<File?> takePicture() async {
    XFile? image;
    bool? isFrontCamera;
    await controllerLock.synchronized(() async {
      if (cameraController == null || !cameraController!.value.isInitialized) {
        return;
      }
      image = await cameraController!.takePicture();
      isFrontCamera = cameraController!.description.lensDirection ==
          CameraLensDirection.front;
    });

    final String filename = ImageService.getImageFileName('.png');
    File? imageFile;
    if (image != null) {
      imageFile = await ImageService.savePhotoToAppGallery(image!, filename);
    }

    if (isFrontCamera == true && imageFile != null) {
      imageFile = await ImageService.mirrorImageHorizontally(imageFile);
    }

    return imageFile;
  }

  /// Wechselt die Kamera.
  Future<void> switchLiveCamera() async {
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    if (camera == null) {
      return;
    }
    await stopCamera();
    await startCamera();
  }

  /// Bild umwandeln und [onImageToProcess] zur Verarbeitung aufrufen.
  void _processCameraImage(final CameraImage image) {
    if (onImageToProcess == null) return;
    // CameraImage in InputImage umwandeln:
    final inputImage = ImageService.inputImageFromCameraImage(
        image, camera!, cameraController);
    if (inputImage == null) {
      SnackBarService.showMessage(
          'Fehler bei der Umwandlung des Bildformates (${InputImageFormatValue.fromRawValue(image.format.raw)})');
      return;
    }

    final int rotationDegrees =
        cameraController!.value.deviceOrientation.degrees -
            cameraController!.description.sensorOrientation;

    if (onImageToProcess != null) {
      onImageToProcess!(inputImage, rotationDegrees);
    }
  }
}

/// Liefert die Gerätsrotation in Grad zurück.
extension DeviceOrientationX on DeviceOrientation {
  int get degrees {
    switch (this) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 90;
      case DeviceOrientation.portraitDown:
        return 180;
      case DeviceOrientation.landscapeRight:
        return 270;
    }
  }
}
