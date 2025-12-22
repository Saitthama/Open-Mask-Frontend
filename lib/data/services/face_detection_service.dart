import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:synchronized/synchronized.dart';

/// Service zur Verwaltung der Gesichtserkennung bzw. des Gesichtstrackings.
class FaceDetectionService extends ChangeNotifier {
  // TODO: über Settings steuern
  /// Optionen für den Face Detector.
  final _faceDetectorOptions = FaceDetectorOptions(
      enableContours: true,
      // Aktiviert zusätzliche Kontur-Informationen
      enableLandmarks: true,
      // Aktiviert die Erkennung von Augen, Nase, Mund usw.
      enableClassification: true,
      // zusätzliche Klassifikationen: z.B. Lächeln, Augen offen
      minFaceSize: 0.3);

  /// Gibt an, ob gerade eine Bild verarbeitet wird.
  bool _isDetecting = false;

  /// Liste der letzten durch [_processImage] erkannten Gesichter.
  List<Face> _faces = [];

  /// Größe des letzten in [_processImage] verarbeiteten Bildes.
  Size? _imageSize;

  /// Gibt an, ob der [_faceDetector] initialisiert wurde.
  bool _initialized = false;

  /// [FaceDetector] zur Erkennung der Gesichter.
  FaceDetector? _faceDetector;

  /// Liste der letzten durch [processImage] erkannten Gesichter.
  List<Face> get faces => _faces;

  /// Größe des letzten in [processImage] verarbeiteten Bildes.
  Size? get imageSize => _imageSize;

  /// Gibt an, ob der [faceDetector] initialisiert wurde.
  bool get initialized => _initialized;

  /// [FaceDetector] zur Erkennung der Gesichter.
  FaceDetector? get faceDetector => _faceDetector;

  /// Lock-Objekt, welches dazu dient den [faceDetector] zu synchronisieren,
  /// um Race Conditions bei der Initialisierung und Schließung zu verhindern.
  final faceDetectorLock = Lock();

  /// Aktualisiert Gesichter ([faces]) und Bildgröße ([imageSize]) und benachrichtigt Beobachter mit [notifyListeners].
  void _update(final List<Face> newFaces, final Size newImageSize) {
    _faces = newFaces;
    _imageSize = newImageSize;
    notifyListeners();
  }

  /// Initialisiert den [faceDetector] und benachrichtigt Beobachter mit [notifyListeners].
  Future<void> initialize() async {
    await faceDetectorLock.synchronized(() async {
      _initialized = false;
      // FaceDetector initialisieren:
      _faceDetector = FaceDetector(options: _faceDetectorOptions);
      _initialized = true;
    });
    notifyListeners();
  }

  /// Verarbeitet das übergebene [image] und weist die gefundenen Gesichter [faces] zu.
  Future<void> processImage(
      final InputImage image, final int rotationDegrees) async {
    if (_isDetecting) return;
    await _processImage(image, rotationDegrees);
  }

  /// Verarbeitet das übergebene [image] mit dem [faceDetector] unter Einbeziehung der [rotationDegrees]
  /// und ruft [_update] mit den neuen Werten auf. Ruft [initialize] auf, falls der [faceDetector] nicht gesetzt wurde.
  Future<void> _processImage(
      final InputImage image, final int rotationDegrees) async {
    _isDetecting = true;
    if (!initialized) {
      await initialize();
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

  /// Beendet den Bild-Stream und den [faceDetector] und benachrichtigt Beobachter mit [notifyListeners].
  Future<void> stopDetection() async {
    await faceDetectorLock.synchronized(() async {
      _initialized = false;
      await _faceDetector?.close();
      _faceDetector = null;
    });
    notifyListeners();
  }

  @override
  void dispose() {
    stopDetection();
    super.dispose();
  }
}
