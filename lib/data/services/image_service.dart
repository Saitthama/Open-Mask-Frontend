import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/ui/painter/face_filter_painter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Service für bildbezogene Operationen.
class ImageService {
  /// Schwarz-Weiß-Version des App-Icons.
  static final colourlessAppIcon = ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.33,
        0.33,
        0.33,
        0,
        0,
        0.33,
        0.33,
        0.33,
        0,
        0,
        0.33,
        0.33,
        0.33,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: CircleAvatar(
        foregroundImage: Image.asset('assets/images/icons/app-icon.jpeg').image,
        radius: 32,
      ));

  /// Erstellt einen neuen Pfad mit dem angegebenen [imageFile], bei dem das Namensformat einheitlich ist.
  /// Wenn eine [fileExtension] angegeben wird, wird diese anstatt der alten verwendet.
  /// Die [fileExtension] ist im folgenden Format anzugeben:
  /// ```dart
  /// fileExtension = '.png';
  /// fileExtension = '.jpg';
  /// ```
  static String getImageFilePath(final File imageFile,
      {final String? fileExtension}) {
    String fileExtensionForNewPath =
        (fileExtension == null) ? extension(imageFile.path) : fileExtension;
    String newFilename = getImageFileName(fileExtensionForNewPath);
    String newPath = '${imageFile.parent.path}/$newFilename';
    return newPath;
  }

  /// Gibt einen einheitlichen Namen für ein Bild zurück.
  /// Die [fileExtension] ist im folgenden Format anzugeben:
  /// ```dart
  /// fileExtension = '.png';
  /// fileExtension = '.jpg';
  /// ```
  static String getImageFileName(final String fileExtension) {
    return 'open-mask_${DateTime.timestamp()}$fileExtension';
  }

  /// Speichert die angegebene Bilddatei in der Handy-Galerie im Open-Mask-Album.
  static Future<bool> saveImageFileToGallery(final File imageFile) async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }

      await Gal.putImage(imageFile.path, album: 'Open-Mask');
      return true;
    } on GalException catch (e) {
      SnackBarService.showMessage(e.type.message);
      return false;
    }
  }

  /// Löscht das angegebene [imageFile] aus der lokalen App-Galerie.
  static Future<bool> deleteImageFileFromAppGallery(
      final File imageFile) async {
    try {
      await imageFile.delete(recursive: true);
      return true;
    } on GalException catch (e) {
      SnackBarService.showMessage(e.type.message);
      return false;
    }
  }

  /// Lädt ein Bild als [Uint8List] aus einem Asset.
  static Future<Uint8List?> loadImageFromAsset(final String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final list = Uint8List.view(data.buffer);
      return list;
    } catch (e) {
      return null;
    }
  }

  /// Lädt ein Bild als [Uint8List] von einer URL.
  static Future<Uint8List?> loadImageFromURL(final String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode / 100 != 2) {
      SnackBarService.showMessage(
          'Fehler beim Laden des Filter-Bildes von $imageUrl (Status: ${response.statusCode})');
      return null;
    }
    final Uint8List bytes = response.bodyBytes;
    return bytes;
  }

  /// Lädt ein Bild als [Uint8List] aus dem angegebenen [file].
  static Future<Uint8List> loadImageFromFile(final File file) async {
    final data = await file.readAsBytes();
    return data;
  }

  /// Lädt ein Bild als [ui.Image] aus dem angegebenen [file].
  static Future<ui.Image> loadUiImageFromFile(final File file) async {
    final data = await loadImageFromFile(file);
    return await uint8ListToUiImage(data);
  }

  /// Wandelt eine [Uint8List] in ein [ui.Image] um.
  static Future<ui.Image> uint8ListToUiImage(final Uint8List data) async {
    final ui.Codec codec = await ui.instantiateImageCodec(data);
    final ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Wandelt ein [ui.Image] in ein [Uint8List] um.
  static Future<Uint8List> uiImageToUint8List(final ui.Image image,
      {final ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final byteData = await image.toByteData(format: format);
    return byteData!.buffer.asUint8List();
  }

  /// Definiert die Rotation in Grad für die jeweiligen Ausrichtungsrichtungen des Geräts.
  static final orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// Liefert den Galerie-Ordner der App zurück bzw. erstellt diesen, wenn nötig.
  static Future<Directory> getAppGalleryDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final galleryDir = Directory('${dir.path}/photos');

    if (!await galleryDir.exists()) {
      await galleryDir.create(recursive: true);
    }

    return galleryDir;
  }

  /// Speichert ein aufgenommenes Foto ([picture]) in die App-Galerie unter dem Namen [filename].
  static Future<File> savePhotoToAppGallery(
      final XFile picture, final String filename) async {
    final dir = await getAppGalleryDirectory();
    final file = File('${dir.path}/$filename');
    return File(picture.path).copy(file.path);
  }

  /// Speichert das übergebene [image] in die App-Galerie mit dem angegebenen [filename].
  static Future<File> saveUiImageToAppGallery(
      final ui.Image image, final String filename) async {
    final dir = await getAppGalleryDirectory();
    final File file = File('${dir.path}/$filename');
    return saveUiImageToFile(image, file);
  }

  /// Speichert das übergebene [image] in das angegebene [file].
  static Future<File> saveUiImageToFile(
      final ui.Image image, final File file) async {
    final Uint8List imageData = await uiImageToUint8List(image);
    return file.writeAsBytes(imageData, flush: true);
  }

  /// Lädt Fotos aus der App-Galerie.
  static Future<List<File>> loadLocalPhotos() async {
    final dir = await getAppGalleryDirectory();
    final files = Directory(dir.path)
        .listSync()
        .whereType<File>()
        .where((final file) =>
            file.path.endsWith('.png') || file.path.endsWith('.jpg'))
        .toList()
      ..sort((final a, final b) => b.path.compareTo(a.path)); // neueste zuerst

    return files;
  }

  /// Lädt ein Bild aus einem [File], findet Gesichter mit dem [faceDetector] und wendet den [filter] auf sie an.
  static Future<ui.Image> applyFilterToImage(final File imageFile,
      final FaceDetector faceDetector, final IFilter filter) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    final ui.Image image = await ImageService.loadUiImageFromFile(imageFile);

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final painter = FaceFilterPainter(
        faces: faces,
        imageSize: imageSize,
        isFrontCamera: false,
        filter: filter);

    final ui.Image editedImage = await painter.paintOnImage(image);
    return editedImage;
  }

  /// Umwandlung eines [CameraImage] in ein [InputImage], damit es für das Google ML Kit lesbar ist (https://pub.dev/packages/google_mlkit_commons).
  static InputImage? inputImageFromCameraImage(
      final CameraImage image,
      final CameraDescription camera,
      final CameraController? cameraController) {
    if (cameraController == null) return null;
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          orientations[cameraController.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
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
}
