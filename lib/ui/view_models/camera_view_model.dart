import 'package:flutter/material.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/hat_filter.dart';
import 'package:open_mask/filter/templates/mustache_filter.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:provider/provider.dart';

/// View-Model, welches die Logik für den [CameraScreen] und das [CameraView] hält.
class CameraViewModel extends ChangeNotifier with WidgetsBindingObserver {
  CameraViewModel(this.context)
      : cameraService = Provider.of<CameraService>(context, listen: false),
        faceDetectionService =
            Provider.of<FaceDetectionService>(context, listen: false) {
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  /// Context, wo im Widget Tree sich [CameraScreen] befindet.
  final BuildContext context;

  // TODO: Über Settings steuern
  final bool showMarkings = true;
  final bool showLandmarks = true;

  /// Service zur Verwaltung der Gesichtserkennung.
  final FaceDetectionService faceDetectionService;

  /// Service zur Verwaltung der Kamerafunktionen.
  final CameraService cameraService;

  bool initializedAndLive = false;

  // TODO: Filter auswählen
  /// Aktuell ausgewählter Filter.
  IFilter? filter;

  /// Lädt die Filter. Initialisiert die Kamera und Gesichtserkennung über [initializeCamera].
  Future<void> initialize() async {
    initializedAndLive = false;

    await _loadFilter();

    await initializeCamera();

    notifyListeners();
  }

  /// Lädt den Filter in die lokale Variable [filter].
  Future<void> _loadFilter() async {
    // TODO: ersetzen durch Filterauswahl, Filter sollen in der Filter Factory oder im Filter-Editor gebaut werden.
    FilterConfig mustacheConfig = FilterConfig(
        scale: MustacheFilter.defaultScale,
        offset: MustacheFilter.defaultOffset);
    FilterMeta meta = FilterMeta(
        name: 'Mustache Filter 1', description: 'Unterer Schnurrbart');
    FilterImage mustacheImage = FilterImage(
        filename: MustacheFilter.defaultImageFilename,
        assetPath: MustacheFilter.defaultAssetPath);
    MustacheFilter mustacheFilter = MustacheFilter(
        config: mustacheConfig, meta: meta, filterImage: mustacheImage);

    FilterMeta meta2 = FilterMeta(
        name: 'Mustache Filter 2', description: 'Oberer Schnurrbart');
    FilterConfig config2 = FilterConfig(
        offset: const Offset(0, 10),
        scale: const Scale(0.5, 0.5),
        opacity: 0.5);
    FilterImage onlineMustacheImage = FilterImage(
        filename: 'online_mustache',
        imageUrl: 'https://pngimg.com/uploads/moustache/moustache_PNG43.png');
    MustacheFilter mustacheFilter2 = MustacheFilter(
        config: config2, meta: meta2, filterImage: onlineMustacheImage);

    HatFilter hatFilter = FilterFactory.create(FilterType.hat) as HatFilter;
    hatFilter.meta.name = 'Hat Filter';
    hatFilter.meta.description = 'Hut-Filter';
    hatFilter.config.scale = const Scale(1.3, 1.2);

    FilterMeta metaComposite = FilterMeta(
        name: 'Hut-Schnurrbart-Filter', description: 'Schnurrbart und Hut');
    CompositeFilter compositeFilter = CompositeFilter(meta: metaComposite);
    final filterList = compositeFilter.filterList;
    filterList.add(mustacheFilter);
    filterList.add(mustacheFilter2);
    filterList.add(hatFilter);
    filterList
        .add(FilterFactory.create(FilterType.mask)..config?.opacity = 0.5);
    filter = compositeFilter;
  }

  /// Initialisiert die Kamera und Gesichtserkennung.
  Future<void> initializeCamera() async {
    initializedAndLive = false;
    await faceDetectionService.initialize();
    cameraService.onImage = faceDetectionService.processImage;
    await cameraService.initialize();
    initializedAndLive = true;
  }

  /// Startet die Kamera und Gesichtserkennung.
  Future<void> startCamera() async {
    initializedAndLive = false;
    await faceDetectionService.initialize();
    await cameraService.startCamera();
    initializedAndLive = true;

    notifyListeners();
  }

  /// Nimmt ein Foto auf und wendet, wenn nötig den aktiven Filter darauf an.
  Future<void> _takePicture() async {
    try {
      final image = await cameraService.takePicture();
      // TODO: Bildverarbeitung hier einfügen
    } catch (e) {
      SnackBarService.showMessage('Error taking picture: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      initializedAndLive = false;
      notifyListeners();
      cameraService.stopCamera();
      faceDetectionService.stopDetection();
      //faceMeshDetector?.close();
    } else if (state == AppLifecycleState.resumed) {
      startCamera(); // neu starten
    }
  }

  @override
  void dispose() {
    initializedAndLive = false;
    WidgetsBinding.instance.removeObserver(this);
    cameraService.stopCamera();
    faceDetectionService.stopDetection();
    super.dispose();
  }
}
