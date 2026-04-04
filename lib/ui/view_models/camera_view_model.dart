import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/hat_filter.dart';
import 'package:open_mask/filter/templates/left_eye_color_filter.dart';
import 'package:open_mask/filter/templates/left_eye_filter.dart';
import 'package:open_mask/filter/templates/mask_filter.dart' as om_mf;
import 'package:open_mask/filter/templates/mouth_filter.dart';
import 'package:open_mask/filter/templates/mustache_filter.dart';
import 'package:open_mask/filter/templates/right_eye_color_filter.dart';
import 'package:open_mask/filter/templates/right_eye_filter.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/views/camera_view.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

/// View-Model, welches die Logik für den [CameraScreen] und das [CameraView] hält.
class CameraViewModel extends ChangeNotifier with WidgetsBindingObserver {
  /// Standard-Konstruktor, der die Services lädt und mit [initialize] alles nötige initialisiert.
  CameraViewModel(this.context)
      : cameraService = Provider.of<CameraService>(context, listen: false),
        faceDetectionService =
            Provider.of<FaceDetectionService>(context, listen: false) {
    WidgetsBinding.instance.addObserver(this);
    FilterStore.instance.addListener(notifyListeners);
  }

  /// Context, wo im Widget Tree sich [CameraScreen] befindet.
  final BuildContext context;

  // TODO: Über Settings steuern
  /// Gibt an, ob überhaupt Tracking-Markierungen angezeigt werden sollen.
  bool _showMarkings = true;

  /// Gibt an, ob überhaupt Tracking-Markierungen angezeigt werden sollen.
  bool get showMarkings => _showMarkings;

  /// Gibt an, ob die Gesichtsbox angezeigt werden soll.
  bool _showFaceBox = true;

  /// Gibt an, ob die Gesichtsbox angezeigt werden soll.
  bool get showFaceBox => _showFaceBox;

  /// Gibt an, ob die Landmarken angezeigt werden können.
  bool _showLandmarks = true;

  /// Gibt an, ob die Landmarken angezeigt werden können.
  bool get showLandmarks => _showLandmarks;

  /// Gibt an, ob Gesichtskonturen gezeigt werden sollen.
  bool _showContours = true;

  /// Gibt an, ob Gesichtskonturen gezeigt werden sollen.
  bool get showContours => _showContours;

  /// Service zur Verwaltung der Gesichtserkennung.
  final FaceDetectionService faceDetectionService;

  /// Service zur Verwaltung der Kamerafunktionen.
  final CameraService cameraService;

  /// Gibt an, ob die Kamera gerade läuft.
  bool _cameraLive = false;

  /// Gibt an, ob die Kamera gerade gestartet wird.
  bool _startingCamera = false;

  /// Gibt an, ob das View-Model initialisiert wurde.
  bool _initialized = false;

  /// Gibt an, ob die Kamera gewechselt wird.
  bool _changingCamera = false;

  /// Gibt an, ob der Filter angezeigt werden soll.
  bool _filterActive = true;

  /// Gibt an, ob die Kamera gerade läuft.
  bool get cameraLive => _cameraLive;

  /// Gibt an, ob die Kamera gerade gestartet wird.
  bool get startingCamera => _startingCamera;

  /// Gibt an, ob das View-Model initialisiert wurde.
  bool get initialized => _initialized;

  /// Gibt an, ob die Kamera gewechselt wird.
  bool get changingCamera => _changingCamera;

  // TODO: Filter auswählen
  /// Aktuell ausgewählter Filter.
  IFilter? get filter => FilterStore.instance.selectedFilter;

  /// Gibt an, ob der Filter angezeigt werden soll.
  bool get filterActive => _filterActive;

  /// Gibt an, ob die Seite sichtbar wird und wird im [CameraScreen] gesetzt.
  bool pageVisible = false;

  /// Lädt Filter. Initialisiert die Kamera und startet die Gesichtserkennung über [initializeCamera]. <br>
  /// Falls die Initialisierung bereits erfolgt ist ([initialized] == true), wird nur [initializeCamera] ausgeführt.
  Future<void> initialize() async {
    if (initialized) {
      if (!cameraLive) initializeCamera();
      return;
    }
    _cameraLive = false;

    await loadFilter();

    await initializeCamera();
    _initialized = true;

    notifyListeners();
  }

  /// Lädt den Filter in die lokale Variable [filter] und startet das asynchrone Laden der externen Ressourcen mit [IFilter.load].
  Future<void> loadFilter() async {
    // TODO: Vordefinierte Filter als Assets speichern
    // Augen:
    LeftEyeFilter leftEye =
        FilterFactory.create(FilterType.leftEye) as LeftEyeFilter;
    leftEye.meta.name = 'Linkes rotes Auge';
    leftEye.meta.icon = Image.asset(leftEye.defaultAssetPath);
    RightEyeFilter rightEye =
        FilterFactory.create(FilterType.rightEye) as RightEyeFilter;
    rightEye.meta.name = 'Rechtes rotes Auge';
    rightEye.meta.icon = Image.asset(rightEye.defaultAssetPath);
    CompositeFilter eyes =
        FilterFactory.create(FilterType.composite) as CompositeFilter;
    eyes.addFilter(leftEye);
    eyes.addFilter(rightEye);
    eyes.meta.name = 'Rote Augen';
    eyes.meta.description = 'Leuchtende rote Augen';
    eyes.meta.icon = Row(children: [
      Image.asset(leftEye.defaultAssetPath),
      Image.asset(rightEye.defaultAssetPath)
    ]);
    FilterStore.instance.addLocalFilter(eyes);

    // Mund
    FilterStore.instance.addLocalFilter(FilterFactory.create(FilterType.mouth));
    MouthFilter creepyMouth =
        (FilterFactory.create(FilterType.mouth) as MouthFilter)
          ..filterImage = FilterImage(
              filename: 'creepy_mouth',
              assetPath: 'assets/images/filter/creepy_mouth.png')
          ..meta.icon = Image.asset('assets/images/filter/creepy_mouth.png')
          ..meta.name = 'Unheimliches Lächeln'
          ..config.offset = const Offset(0.0, 4.0)
          ..config.scale = const Scale(2.0, 2.0);
    FilterStore.instance.addLocalFilter(creepyMouth);

    // Mund und Augen
    CompositeFilter creepyFace =
        (FilterFactory.create(FilterType.composite) as CompositeFilter)
          ..meta.name = 'Unheimliches Gesicht'
          ..meta.description =
              'Unheimlicher Zusammengesetzter Filter aus Augen und Mund'
          ..meta.icon = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [eyes.meta.icon, creepyMouth.meta.icon],
          );
    creepyFace.addFilter(creepyMouth);
    creepyFace.addFilter(eyes);
    FilterStore.instance.addLocalFilter(creepyFace);

    FilterStore.instance.selectedFilter = creepyFace;

    // Laden der externen Resourcen asynchron starten, damit die Kamera nicht blockiert wird.
    filter?.load();

    // Composite-Filter
    MustacheFilter mustache1 = (FilterFactory.create(FilterType.mustache)
        as MustacheFilter)
      ..meta.description = 'Standardschnurrbart';
    MustacheFilter mustache2 = (FilterFactory.create(FilterType.mustache)
        as MustacheFilter)
      ..config.offset = const Offset(0, -11.5)
      ..config.scale = const Scale(0.5, 0.5)
      ..config.opacity = 0.5
      ..filterImage = FilterImage(
          filename: 'online_mustache',
          imageUrl: 'https://pngimg.com/uploads/moustache/moustache_PNG43.png');
    HatFilter hatFilter = (FilterFactory.create(FilterType.hat) as HatFilter)
      ..meta.name = 'Hut-Filter'
      ..meta.description = 'Filter mit dem Standardhut';
    om_mf.MaskFilter maskFilter = ((FilterFactory.create(FilterType.mask)
      ..config?.opacity = 0.5) as om_mf.MaskFilter);
    maskFilter.meta.name = 'Transparente Maske';
    maskFilter.meta.icon =
        Opacity(opacity: 0.5, child: Image.asset(maskFilter.defaultAssetPath));
    FilterMeta metaComposite = FilterMeta(
        name: 'Hut-Schnurrbart-Filter', description: 'Schnurrbart und Hut');
    CompositeFilter compositeFilter = CompositeFilter(meta: metaComposite);
    compositeFilter.addFilter(mustache1);
    compositeFilter.addFilter(mustache2);
    compositeFilter.addFilter(hatFilter);
    compositeFilter.addFilter(maskFilter);

    FilterStore.instance.addLocalFilter(compositeFilter);

    om_mf.MaskFilter mask = (FilterFactory.create(FilterType.mask)
        as om_mf.MaskFilter)
      ..meta.name = 'Standardmaske';
    CompositeFilter hatAndMask =
        (FilterFactory.create(FilterType.composite) as CompositeFilter)
          ..meta.name = 'Hut & Maske'
          ..meta.description = 'Zusammengesetzter Filter mit Hut & Maske';
    hatAndMask.addFilter(mask);
    hatAndMask.addFilter(hatFilter);
    FilterStore.instance.addLocalFilter(hatAndMask);

    // Hüte:
    FilterStore.instance.addLocalFilter(FilterFactory.create(FilterType.hat));
    HatFilter cowboyHat = (FilterFactory.create(FilterType.hat) as HatFilter)
      ..filterImage = FilterImage(
          filename: 'detective_hat',
          assetPath: 'assets/images/filter/detective_hat.png')
      ..meta.name = 'Detektivhut'
      ..meta.description = 'Brauner Detektivhut'
      ..meta.icon = Image.asset('assets/images/filter/detective_hat.png')
      ..config.scale = const Scale(1.65, 1.65)
      ..config.offset = const Offset(0, -14);
    FilterStore.instance.addLocalFilter(cowboyHat);
    HatFilter brownHat = (FilterFactory.create(FilterType.hat) as HatFilter)
      ..filterImage = FilterImage(
          filename: 'brown_hat',
          assetPath: 'assets/images/filter/brown_hat.png')
      ..meta.name = 'Brauner Hut'
      ..meta.description = 'Brauner Standardhut'
      ..meta.icon = Image.asset('assets/images/filter/brown_hat.png')
      ..config.scale = const Scale(1.65, 1.65)
      ..config.offset = const Offset(0, -14);
    FilterStore.instance.addLocalFilter(brownHat);

    // Masken:
    FilterStore.instance.addLocalFilter(FilterFactory.create(FilterType.mask));

    // Farbaugen
    IFilter leftColorEye = (FilterFactory.create(FilterType.leftColorEye)
        as LeftEyeColorFilter)
      ..color = Colors.red;
    IFilter rightColorEye = (FilterFactory.create(FilterType.rightColorEye)
        as RightEyeColorFilter)
      ..color = Colors.red;
    CompositeFilter colorEyes =
        FilterFactory.create(FilterType.composite) as CompositeFilter;
    colorEyes.meta.name = 'Farbaugen';
    Widget eyeIcon = const Icon(
      Icons.remove_red_eye_rounded,
      color: Colors.black,
    );
    colorEyes.meta.icon = Row(spacing: 5, children: [eyeIcon, eyeIcon]);
    colorEyes.addFilter(leftColorEye);
    colorEyes.addFilter(rightColorEye);
    FilterStore.instance.addLocalFilter(colorEyes);
  }

  /// Initialisiert die Kamera und Gesichtserkennung.
  Future<void> initializeCamera() async {
    _cameraLive = false;
    await faceDetectionService.initialize();
    cameraService.onImageToProcess = faceDetectionService.processImage;
    await cameraService.initialize();
    if (cameraService.camera == null) {
      return;
    }
    _cameraLive = true;
    notifyListeners();
  }

  /// Startet die Kamera und Gesichtserkennung.
  Future<void> startCamera() async {
    _cameraLive = false;
    _startingCamera = true;
    notifyListeners();
    await faceDetectionService.initialize();
    await cameraService.startCamera();
    _startingCamera = false;
    _cameraLive = true;

    notifyListeners();
  }

  /// Stoppt die Kamera und Gesichtserkennung.
  Future<void> stopCamera() async {
    _cameraLive = false;
    notifyListeners();
    await cameraService.stopCamera();
    await faceDetectionService.stopDetection();
  }

  /// Nimmt ein Foto auf und wendet, wenn nötig den aktiven Filter darauf an.
  Future<void> takePicture() async {
    try {
      final imageFile = await cameraService.takePicture();
      if (imageFile == null) {
        SnackBarService.showMessage('Kamera noch nicht initialisiert');
        return;
      }

      if (filter == null ||
          !filterActive ||
          faceDetectionService.faceDetector == null) {
        return;
      }

      final ui.Image editedImage = await ImageService.applyFilterToImage(
          imageFile, faceDetectionService.faceDetector!, filter!);

      final File editedFile = await ImageService.saveUiImageToAppGallery(
          editedImage, basename(imageFile.path));
    } catch (e) {
      SnackBarService.showMessage('Error taking picture: $e');
    }
  }

  /// Ändert die Kamera und startet sie neu. [changingCamera] gibt an, ob es noch geändert wird, oder der Wechsel abgeschlossen ist.
  Future<void> switchLiveCamera() async {
    _changingCamera = true;
    notifyListeners();
    await cameraService.switchLiveCamera();
    _changingCamera = false;
    notifyListeners();
  }

  /// Schaltet den Filter um ([filterActive]). Wenn der Filter eingeschaltet ist, wird er ausgeschaltet und umgekehrt eingeschaltet.
  void switchFilterActive() {
    _filterActive = !_filterActive;
    notifyListeners();
  }

  /// Schaltet die Gesichtsmarkierungen um ([showMarkings]). Wenn diese eingeschaltet sind, werden sie ausgeschaltet und umgekehrt eingeschaltet.
  void switchShowMarkings() {
    _showMarkings = !_showMarkings;
    notifyListeners();
  }

  /// Schaltet die Gesichtsbox um ([showFaceBox]). Wenn diese eingeschaltet sind, werden sie ausgeschaltet und umgekehrt eingeschaltet.
  void switchShowFaceBox() {
    _showFaceBox = !_showFaceBox;
    notifyListeners();
  }

  /// Schaltet die Landmarken um ([showLandmarks]). Wenn diese eingeschaltet sind, werden sie ausgeschaltet und umgekehrt eingeschaltet.
  void switchShowLandmarks() {
    _showLandmarks = !_showLandmarks;
    notifyListeners();
  }

  /// Schaltet die Gesichtskonturen um ([showContours]). Wenn diese eingeschaltet sind, werden sie ausgeschaltet und umgekehrt eingeschaltet.
  void switchShowContours() {
    _showContours = !_showContours;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (!pageVisible) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      startCamera(); // neu starten
    }
  }

  @override
  void dispose() {
    FilterStore.instance.selectedFilter = null;
    _cameraLive = false;
    pageVisible = false;
    WidgetsBinding.instance.removeObserver(this);
    cameraService.stopCamera();
    faceDetectionService.stopDetection();
    super.dispose();
  }
}
