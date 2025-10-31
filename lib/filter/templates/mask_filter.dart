import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/geometry_service.dart';
import 'package:open_mask/filter/configs/image_filter_config.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/image_filter.dart';

/// Filter, welcher eine Maske über das Gesicht legt (Positionierung basierend auf der Bounding-Box des Gesichts).
class MaskFilter extends ImageFilter {
  /// Standard-Konstruktor.
  MaskFilter({super.id, required super.meta, required super.config})
      : super(type: FilterType.mask);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory MaskFilter.fromJSON(final Map<String, dynamic> json) {
    Map<String, dynamic> configJson = json['config'] ?? {};
    configJson.putIfAbsent('imagePath', () => defaultImagePath);
    configJson.putIfAbsent('offsetX', () => defaultOffset.dx);
    configJson.putIfAbsent('offsetY', () => defaultOffset.dy);

    ImageFilterConfig imageFilterConfig =
        ImageFilterConfig.fromJSON(configJson);

    return MaskFilter(
        id: int.parse(json['id']),
        meta: FilterMeta.fromJson(json['meta']),
        config: imageFilterConfig);
  }

  /// Standarmäßiger Asset-Path ([config.imagePath]).
  static const String defaultImagePath = 'assets/images/mask.png';

  /// Standardmäßige relative Position der Maske.
  static const Offset defaultOffset = Offset(0.0, 25);

  @override
  void apply(final Face face, final Canvas canvas, final Size canvasSize,
      final Scale scale, final bool isFrontCamera) {
    if (image == null) {
      if (!isLoading) load();
      return;
    }

    final landmarks = face.landmarks;
    if (landmarks.isEmpty) return;

    final double canvasWidth = min(canvasSize.width, canvasSize.height);

    // Gesichtsdaten
    final faceBox = face.boundingBox;
    final faceCenter = Offset(
      isFrontCamera
          ? canvasWidth - faceBox.center.dx * scale.scaleX
          : faceBox.center.dx * scale.scaleX,
      faceBox.center.dy * scale.scaleY,
    );
    final faceWidth = faceBox.width * scale.scaleX;
    final faceHeight = faceBox.height * scale.scaleY;

    // Skalierung aus der Config
    final double width = faceWidth * config.scale.scaleX;
    final double height = faceHeight * config.scale.scaleY;

    // Offset relativ zur Gesichtsgröße, rotiert mit Gesicht
    final Offset relativeOffset =
        GeometryService.scaleOffset(config.offset, faceWidth, faceHeight);

    final totalRotation = GeometryService.calculateFaceZRotation(
        face, config.rotation, isFrontCamera);

    // Rotiertes Offset anwenden
    Offset rotatedOffset =
        GeometryService.rotateOffset(relativeOffset, totalRotation);

    // Zielrechteck für die Maske
    final Rect maskRect = Rect.fromCenter(
      center: faceCenter + rotatedOffset,
      width: width,
      height: height,
    );

    // Canvas-Transformationen
    canvas.save();

    // Um Mittelpunkt der Maske rotieren
    canvas.translate(maskRect.center.dx, maskRect.center.dy);
    canvas.rotate(isFrontCamera ? -totalRotation : totalRotation);
    canvas.translate(-maskRect.center.dx, -maskRect.center.dy);

    // Maske zeichnen
    paintImage(
      canvas: canvas,
      rect: maskRect,
      image: image!,
      opacity: config.opacity,
      filterQuality: FilterQuality.high,
    );

    canvas.restore();
  }
}
