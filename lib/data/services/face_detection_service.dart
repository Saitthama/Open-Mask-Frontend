import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

/// Service zur Verwaltung der Gesichtserkennung bzw. des Gesichtstrackings.
class FaceDetectionService extends ChangeNotifier {
  bool _isDetecting = false;
  List<Face> _faces = [];
  Size? _imageSize;

  /// [FaceDetector] zur Erkennung der Gesichter.
  FaceDetector? _faceDetector;

  bool _initialized = false;

  bool get initialized => _initialized;

  List<Face> get faces => _faces;

  Size? get imageSize => _imageSize;

  /// [FaceDetector] zur Erkennung der Gesichter.
  FaceDetector? get faceDetector => _faceDetector;

  // TODO: über Settings steuern
  /// Optionen für den Face Detector
  final _faceDetectorOptions = FaceDetectorOptions(
      enableContours: true,
      // Aktiviert zusätzliche Kontur-Informationen
      enableLandmarks: true,
      // Aktiviert die Erkennung von Augen, Nase, Mund usw.
      enableClassification: true,
      // zusätzliche Klassifikationen: z.B. Lächeln, Augen offen
      minFaceSize: 0.3);

  /// Aktualisiert Gesichter ([faces]) und Bildgröße ([imageSize]) und benachrichtigt Beobachter.
  void _update(final List<Face> newFaces, final Size newImageSize) {
    _faces = newFaces;
    _imageSize = newImageSize;
    notifyListeners();
  }

  /// Initialisiert den [faceDetector].
  Future<void> initialize() async {
    _initialized = false;
    // FaceDetector initialisieren:
    _faceDetector = FaceDetector(options: _faceDetectorOptions);
    _initialized = true;
    notifyListeners();
  }

  Future<void> processImage(
      final InputImage image, final int rotationDegrees) async {
    if (_isDetecting) return;
    _processImage(image, rotationDegrees);
  }

  Future<void> _processImage(
      final InputImage image, final int rotationDegrees) async {
    _isDetecting = true;
    if (faceDetector == null) {
      return;
    }
    try {
      // Größe zuweisen
      image.metadata?.rotation;

      Size imageSize = image.metadata!.size;

      // Rotation vertauschen, falls 90° oder 270° Rotation
      if (rotationDegrees.abs() == 90 || rotationDegrees.abs() == 270) {
        imageSize = Size(imageSize.height, imageSize.width);
      }

      // Bild mit dem FaceDetector verarbeiten:
      final List<Face> detectedFaces = await _faceDetector!.processImage(image);

      _update(detectedFaces, imageSize);
    } catch (e) {
      SnackBarService.showMessage('Fehler bei der Verarbeitung des Bildes: $e');
    } finally {
      _isDetecting = false;
    }
  }

  /// Beendet den Bild-Stream und den [faceDetector].
  Future<void> stopDetection() async {
    _initialized = false;
    await _faceDetector?.close();
    _faceDetector = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopDetection();
    super.dispose();
    _initialized = false;
  }
}
