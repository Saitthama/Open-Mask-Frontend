import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/ui/screens/filter_editor_screen.dart';
import 'package:open_mask/ui/views/filter_editor_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

/// View-Model, welches die Logik für den [FilterEditorScreen] und das [FilterEditorView] hält.
class FilterEditorViewModel extends ChangeNotifier {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>Der [context] wird für die Initialisierung des [faceDetectionService] benötigt, um die Dummy-Gesichter zu erkennen.</li>
  /// </ul>
  FilterEditorViewModel(final BuildContext context)
      : faceDetectionService =
            Provider.of<FaceDetectionService>(context, listen: false) {
    FilterStore.instance.addListener(() => notifyListeners());
  }

  /// Service für die Erkennung der Dummy-Gesichter.
  final FaceDetectionService faceDetectionService;

  /// Liste von Asset-Pfaden für verschiedene Dummy-Modelle.
  final List<String> _dummyAssetPaths = [
    'assets/images/dummys/editor-dummy.png',
    'assets/images/dummys/editor-dummy-v2.png',
    'assets/images/dummys/editor-dummy-female.png'
  ];

  /// Index des aktuell ausgewählten Dummys.
  int _selectedDummyIndex = 0;

  /// Enthält alle Dummy-Gesichter.
  final List<List<Face>> _dummyFacesList = [];

  /// Enthält die Größe des verarbeiteten Dummy-Bildes.
  final List<Size?> _processedDummySizes = [];

  /// Gibt an, ob Markierungen angezeigt werden sollen.
  bool _showMarkings = true;

  /// Gibt an, ob die Gesichtsbox des Dummys angezeigt werden soll.
  bool _showFaceBox = true;

  /// Gibt an, ob erkannte Punkte wie Nasen, Augen, Ohren, o.ä. des Dummys ebenfalls visualisiert werden sollen.
  bool _showLandmarks = true;

  /// Gibt an, ob Gesichtskonturen des Dummys ebenfalls visualisiert werden sollen.
  bool _showContours = true;

  /// Asset-Pfad des Dummy-Bildes.
  String get dummyAssetPath => _dummyAssetPaths[_selectedDummyIndex];

  /// Der Filter, welcher aktuell bearbeitet wird.
  IFilter? get currentFilter => FilterStore.instance.currentlyEditedFilter;

  /// Der Filter, welcher aktuell im Editor ausgewählt ist.
  /// Kann sowohl [currentFilter] als auch ein Teile eines [CompositeFilter] sein.
  IFilter? get selectedEditedFilter =>
      FilterStore.instance.selectedEditedFilter;

  /// Enthält das aktuelle Dummy-Gesicht bzw. aktuelle Dummy-Gesichter.
  List<Face> get dummyFaces => _selectedDummyIndex >= _dummyFacesList.length
      ? []
      : _dummyFacesList[_selectedDummyIndex];

  /// Enthält die Größe des verarbeiteten Dummy-Bildes.
  Size? get processedDummySize =>
      _selectedDummyIndex >= _processedDummySizes.length
          ? null
          : _processedDummySizes[_selectedDummyIndex];

  /// Gibt an, ob die Gesichtsbox des Dummys angezeigt werden soll.
  bool get showFaceBox => _showFaceBox;

  /// Gibt an, ob erkannte Punkte wie Nasen, Augen, Ohren, o.ä. des Dummys ebenfalls visualisiert werden sollen.
  bool get showLandmarks => _showLandmarks;

  /// Gibt an, ob Gesichtskonturen des Dummys ebenfalls visualisiert werden sollen.
  bool get showContours => _showContours;

  /// Gibt an, ob Markierungen angezeigt werden sollen.
  bool get showMarkings => _showMarkings;

  /// Gibt an, ob der Filter bereits gespeichert wurde.
  bool get saved => FilterStore.instance.localFilters.contains(currentFilter);

  /// Initialisiert wichtige Properties, z.B. durch das Laden der Gesichter der Dummys.
  Future<void> initialize() async {
    _dummyFacesList.clear();
    _processedDummySizes.clear();
    for (int i = 0; i < _dummyAssetPaths.length; i++) {
      _dummyFacesList.add([]);
      _processedDummySizes.add(null);
      await _detectDummyFaces(i);
    }
    FilterStore.instance.evaluateSelectedEditedFilter();
    //notifyListeners();
  }

  /// Erkennt die Dummy-Gesichter auf dem Bild aus dem Asset aus [_dummyAssetPaths] an der Stelle des [index].
  Future<void> _detectDummyFaces(final int index) async {
    faceDetectionService.initialize();
    FaceDetector? faceDetector = faceDetectionService.faceDetector;
    if (faceDetector == null) {
      return;
    }

    // 1. Asset als ByteData laden
    final Uint8List? byteData =
        await ImageService.loadImageFromAsset(_dummyAssetPaths[index]);

    if (byteData == null) {
      return;
    }

    // 2. Temporäre Datei erstellen
    final file = File(
        '${(await getTemporaryDirectory()).path}/${_dummyAssetPaths[index].split('/').last}');

    // 3. Bytes in die Datei schreiben
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    // 4. InputImage aus dem Dateipfad erzeugen
    InputImage inputImage = InputImage.fromFilePath(file.path);

    _processedDummySizes[index] = await ImageService.getImageSize(file);

    _dummyFacesList[index] = await faceDetector.processImage(inputImage);
    faceDetector.close();
  }

  /// Löscht den [selectedEditedFilter]. Falls der [selectedEditedFilter] der [currentFilter] ist, werden beide gelöscht.
  /// Falls er Teil des [currentFilter] ist, wird nur der [selectedEditedFilter] aus dem [CompositeFilter] gelöscht.
  void delete() {
    if (currentFilter is! CompositeFilter ||
        currentFilter == selectedEditedFilter) {
      FilterStore.instance.selectedEditedFilter = null;
      FilterStore.instance.currentlyEditedFilter = null;
    } else {
      CompositeFilter composite = currentFilter as CompositeFilter;

      composite.removeFilter(selectedEditedFilter);
      FilterStore.instance.evaluateSelectedEditedFilter();

      //notifyListeners(); // wird bereits durch den FilterStore indirekt aufgerufen
    }
  }

  /// Überprüft, ob der [currentFilter] bereits existiert und speichert ihn gegebenenfalls.
  /// Entfernt [currentFilter] aus der Bearbeitung, falls dieser zuvor schon gespeichert wurde.
  void save() {
    if (currentFilter == null) {
      return;
    }
    if (saved) {
      FilterStore.instance.currentlyEditedFilter = null;
    } else {
      FilterStore.instance.addLocalFilter(currentFilter!);
    }
  }

  /// Wechselt den [dummyAssetPath] zum nächsten Dummy.
  void switchDummy() {
    _selectedDummyIndex += 1;
    if (_selectedDummyIndex >= _dummyAssetPaths.length) {
      _selectedDummyIndex = 0;
    }
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
}
