import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:open_mask/data/services/snackbar_service.dart';

/// Service für bildbezogene Operationen.
class ImageService {
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
          'Fehler beim Laden des Filter-Bildes: ${response.statusCode}');
      return null;
    }
    final Uint8List bytes = response.bodyBytes;
    return bytes;
  }

  /// Wandelt eine [Uint8List] in ein [ui.Image] um.
  static Future<ui.Image> uint8ListToUiImage(final Uint8List data) async {
    final ui.Codec codec = await ui.instantiateImageCodec(data);
    final ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Wandelt ein [ui.Image] in ein [Uint8List] um.
  static Future<Uint8List> uiImageToUint8List(final ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Definiert die Rotation in Grad für die jeweiligen Ausrichtungsrichtungen des Geräts.
  static final orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

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
