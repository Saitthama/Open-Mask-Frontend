import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/services/geometry_service.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
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

  /// Standarmäßiger Asset-Path ([FilterImage.assetPath]).
  static const String defaultAssetPath = 'assets/images/filter/hat.png';

  /// Standardmäßiger Dateiname des Filter-Bildes ([FilterImage.filename]).
  static const String defaultImageFilename = 'hat';

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    if (filterImage.image == null) return;

    final landmarks = face.landmarks;

    // Wichtige Landmarken prüfen
    final leftEye = landmarks[FaceLandmarkType.leftEye];
    final rightEye = landmarks[FaceLandmarkType.rightEye];
    final noseBase = landmarks[FaceLandmarkType.noseBase];

    if (leftEye == null || rightEye == null || noseBase == null) return;

    // Gesichtsmitte aus Landmarken berechnen
    final leftEyePosition = fgc.transformPoint(leftEye.position);
    final rightEyePosition = fgc.transformPoint(rightEye.position);
    final eyeCenter =
        GeometryService.midpoint(leftEyePosition, rightEyePosition);

    // Gesichtszentrum und Breite/Höhe bestimmen
    final noseBasePosition = fgc.transformPoint(noseBase.position);
    final faceCenter = GeometryService.midpoint(eyeCenter, noseBasePosition);

    final faceWidth = fgc.transformBoundingBox(face.boundingBox).width;
    final faceHeight = fgc.transformBoundingBox(face.boundingBox).height;

    // Rotation berechnen
    final totalRotation =
        fgc.calculateFaceZRotation(face, extraRotation: config.rotation);

    // Skalierung & Offsets aus Config
    final hatWidth = faceWidth * config.scale.scaleX;
    final hatHeight = faceHeight * config.scale.scaleY;

    final hatOffsetY = -0.6 * hatHeight;
    final offset =
        GeometryService.scaleOffset(config.offset, faceWidth, faceHeight);
    final totalOffset = Offset(offset.dx, offset.dy + hatOffsetY);
    final rotatedOffset =
        GeometryService.rotateOffset(totalOffset, totalRotation);

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
    canvas.rotate(totalRotation);
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
