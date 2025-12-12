import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:provider/provider.dart';

/// View-Model, welches die Logik für den [FilterImageProcessingScreen] und das [CameraView] hält.
class FilterImageProcessingViewModel extends ChangeNotifier {
  /// Der Filter, der auf ausgewählte Bilder angewandt werden soll. Falls kein Filter ausgewählt war, wird ein leerer [CompositeFilter] als Platzhalter verwendet.
  IFilter get filter => (FilterStore.instance.selectedFilter != null)
      ? FilterStore.instance.selectedFilter!
      : FilterFactory.create(FilterType.composite);

  /// Dient zum Auswählen von Bildern.
  late ImagePicker _imagePicker;

  /// Dateipfad des aktuellen Bildes.
  File? _imageFile;

  /// Dateipfad des aktuellen Bildes.
  File? get imageFile => _imageFile;

  /// [FaceDetector] zur Erkennung der Gesichter auf dem Bild.
  FaceDetector? _faceDetector;

  /// [FaceDetector] zur Erkennung der Gesichter auf dem Bild.
  FaceDetector? get faceDetector => _faceDetector;

  /// Gibt an, ob der Filter gerade auf das Bild angewandt wird.
  bool _isProcessing = false;

  /// Gibt an, ob der Filter gerade auf das Bild angewandt wird.
  bool get isProcessing => _isProcessing;

  /// Initialisiert das View-Model und die nötigen Attribute wie z.B. den [faceDetector] und holt sich den aktuellen [filter].
  Future<void> initialize(final BuildContext context) async {
    _faceDetector =
        Provider.of<FaceDetectionService>(context, listen: false).faceDetector;
    _imagePicker = ImagePicker();
  }

  /// Speichert das Bild mit dem angewandten Filter in der Galerie.
  Future<void> save() async {
    if (_imageFile == null) {
      return;
    }
    bool success = await ImageService.saveImageFileToGallery(_imageFile!);
    if (success) {
      SnackBarService.showMessage('Bild erfolgreich in Galerie gespeichert');
    }
  }

  /// Wählt ein Bild mithilfe des [_imagePicker] von der angegebenen Quelle, wendet den Filter an,
  /// weißt es als File [_imageFile] zu und konvertiert es in ein [ui.Image] für die Zuweisung an [_image].
  Future<void> pickAndProcessImage(final ImageSource source) async {
    XFile? xFileImage = await _imagePicker.pickImage(source: source);
    if (xFileImage == null) {
      return;
    }

    File imageFile = File(xFileImage.path);
    imageFile =
        await imageFile.rename(ImageService.getImageFilePath(imageFile));

    _imageFile = imageFile;
    notifyListeners();

    if (_faceDetector != null) {
      _isProcessing = true;
      notifyListeners();
      ui.Image editedImage = await ImageService.applyFilterToImage(
          imageFile, _faceDetector!, filter);
      File editedImageFile =
          File(ImageService.getImageFilePath(imageFile, fileExtension: '.png'));
      await ImageService.saveUiImageToFile(editedImage, editedImageFile);
      _isProcessing = false;
      _imageFile = editedImageFile;
      notifyListeners();
    }
  }
}
