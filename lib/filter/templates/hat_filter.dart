import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/geometry_service.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/image_filter.dart';

/// Filter, der einen Hut auf dem Kopf platziert.
class HatFilter extends ImageFilter {
  /// Standard-Konstruktor.
  HatFilter(
      {super.id,
      required super.meta,
      required super.config,
      required super.filterImage})
      : super(type: FilterType.hat);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory HatFilter.fromJSON(final Map<String, dynamic> json) {
    Map<String, dynamic> filterImageJson = json['filterImage'] ?? {};
    filterImageJson.putIfAbsent('assetPath', () => defaultAssetPath);
    filterImageJson.putIfAbsent('filename', () => defaultImageFilename);
    FilterImage filterImage = FilterImage.fromJSON(filterImageJson);

    FilterConfig filterConfig = FilterConfig.fromJSON(json['config'] ?? {});

    return HatFilter(
        id: int.tryParse(json['id']),
        meta: FilterMeta.fromJson(json['meta']),
        config: filterConfig,
        filterImage: filterImage);
  }

  /// Standarmäßiger Asset-Path ([filterImage.assetPath]).
  static const String defaultAssetPath = 'assets/images/filter/hat.png';

  /// Standardmäßiger Dateiname des Filter-Bildes ([filterImage.filename]).
  static const String defaultImageFilename = 'hat';

  @override
  void apply(final Face face, final Canvas canvas, final Size canvasSize,
      final Scale scale, final bool isFrontCamera) {
    if (filterImage.image == null) {
      if (!filterImage.isLoading) {
        filterImage.load();
      }
      return;
    }

    final landmarks = face.landmarks;

    final double canvasWidth = min(canvasSize.width, canvasSize.height);

    // Wichtige Landmarken prüfen
    final leftEye = landmarks[FaceLandmarkType.leftEye];
    final rightEye = landmarks[FaceLandmarkType.rightEye];
    final noseBase = landmarks[FaceLandmarkType.noseBase];

    if (leftEye == null || rightEye == null || noseBase == null) return;

    // Gesichtsmitte aus Landmarken berechnen
    final leftEyePosition = Offset(
        isFrontCamera
            ? canvasWidth - leftEye.position.x * scale.scaleX
            : leftEye.position.x * scale.scaleX,
        leftEye.position.y * scale.scaleY);
    final rightEyePosition = Offset(
        isFrontCamera
            ? canvasWidth - rightEye.position.x * scale.scaleX
            : rightEye.position.x * scale.scaleX,
        rightEye.position.y * scale.scaleY);
    final eyeCenter =
        GeometryService.midpoint(leftEyePosition, rightEyePosition);

    // Gesichtszentrum und Breite/Höhe bestimmen
    final noseBasePosition = Offset(
        isFrontCamera
            ? canvasWidth - noseBase.position.x * scale.scaleX
            : noseBase.position.x * scale.scaleX,
        noseBase.position.y * scale.scaleY);
    final faceCenter = GeometryService.midpoint(eyeCenter, noseBasePosition);

    final faceWidth = face.boundingBox.width * scale.scaleX;
    final faceHeight = face.boundingBox.height * scale.scaleY;

    // Rotation berechnen
    final faceRotation =
        (isFrontCamera ? -face.headEulerAngleZ! : face.headEulerAngleZ!) *
            pi /
            180;

    final extraRotation =
        (isFrontCamera ? -config.rotation : config.rotation) * pi / 180;
    final totalRotation = faceRotation + extraRotation;

    // Skalierung & Offsets aus Config
    final configScaleX = config.scale.scaleX;
    final configScaleY = config.scale.scaleY;

    final hatWidth = faceWidth * configScaleX;
    final hatHeight = faceHeight * configScaleY;

    final hatOffsetY = -0.6 * hatHeight;
    final offset = Offset((config.offset.dx) / 100 * faceWidth,
        (config.offset.dy) / 100 * faceHeight + hatOffsetY);
    final rotatedOffset = GeometryService.rotateOffset(offset, totalRotation);

    // Stirnposition oberhalb des Gesichts
    final hatPosition = Offset(
        faceCenter.dx + rotatedOffset.dx, faceCenter.dy + rotatedOffset.dy);

    // Bild korrekt transformieren und malen
    final hatRect = Rect.fromCenter(
      center: hatPosition,
      width: hatWidth,
      height: hatHeight,
    );

    canvas.save();

    // Gesichtsrotation (Neigung) + ExtraRotation anwenden
    canvas.translate(hatRect.center.dx, hatRect.center.dy);
    canvas.rotate(isFrontCamera ? -totalRotation : totalRotation);
    canvas.translate(-hatRect.center.dx, -hatRect.center.dy);

    // Das Bild zeichnen
    paintImage(
      canvas: canvas,
      rect: hatRect,
      image: filterImage.image!,
      fit: (filterImage.image!.height.toDouble() / hatHeight >
              filterImage.image!.width.toDouble() / hatWidth)
          ? BoxFit.fitHeight
          : BoxFit.fitWidth,
      opacity: config.opacity,
      filterQuality: FilterQuality.high,
    );

    canvas.restore();
  }
}
