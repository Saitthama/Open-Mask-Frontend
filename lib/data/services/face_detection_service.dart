import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

/// Service zur Verwaltung der Gesichtserkennung.
class FaceDetectionService extends ChangeNotifier {
  FaceDetectionService();

  bool _isDetecting = false;
  List<Face> _faces = [];
  Size? _imageSize;
  FaceDetector? _faceDetector;

  bool _initialized = false;

  bool get initialized => _initialized;

  List<Face> get faces => _faces;

  Size? get imageSize => _imageSize;

  FaceDetector? get faceDetector => _faceDetector;

  // aktualisiert Variablen und benachrichtigt Beobachter
  void _update(final List<Face> newFaces, final Size newImageSize) {
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
    _initialized = false;
    // FaceDetector initialisieren:
    _faceDetector = FaceDetector(options: _faceDetectorOptions);
    _initialized = true;
    notifyListeners();
  }

  Future<void> processImage(final InputImage image) async {
    if (_isDetecting) return;
    _processImage(image);
  }

  Future<void> _processImage(final InputImage image) async {
    _isDetecting = true;
    if (faceDetector == null) {
      return;
    }
    try {
      // Originalgröße zuweisen
      Size newImageSize = image.metadata!.size;

      // Bild mit dem FaceDetector verarbeiten:
      final List<Face> detectedFaces = await _faceDetector!.processImage(image);

      _update(detectedFaces, newImageSize);
    } catch (e) {
      SnackBarService.showMessage('Fehler bei der Verarbeitung des Bildes: $e');
    } finally {
      _isDetecting = false;
    }
  }

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
  }
}
