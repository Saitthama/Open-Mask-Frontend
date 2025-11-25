import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/services/geometry_service.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/configs/image_filter_config.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/image_filter.dart';

/// Filter, welcher eine Maske über das Gesicht legt (Positionierung basierend auf der Bounding-Box des Gesichts).
class MaskFilter extends ImageFilter {
  /// Standard-Konstruktor.
  MaskFilter(
      {super.id,
      required super.meta,
      required super.config,
      required super.filterImage})
      : super(type: FilterType.mask);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory MaskFilter.fromJSON(final Map<String, dynamic> json) {
    Map<String, dynamic> configJson = json['config'] ?? {};
    configJson.putIfAbsent('offsetX', () => defaultOffset.dx);
    configJson.putIfAbsent('offsetY', () => defaultOffset.dy);

    FilterConfig filterConfig = FilterConfig.fromJSON(configJson);

    Map<String, dynamic> filterImageJson = json['filterImage'] ?? {};
    filterImageJson.putIfAbsent('assetPath', () => defaultAssetPath);
    filterImageJson.putIfAbsent('filename', () => defaultImageFilename);
    FilterImage filterImage = FilterImage.fromJSON(filterImageJson);

    return MaskFilter(
        id: int.tryParse(json['id']),
        meta: FilterMeta.fromJson(json['meta']),
        config: filterConfig,
        filterImage: filterImage);
  }

  /// Standarmäßiger Asset-Path ([FilterImage.assetPath]).
  static const String defaultAssetPath = 'assets/images/filter/mask.png';

  /// Standardmäßiger Dateiname des Filter-Bildes ([FilterImage.filename]).
  static const String defaultImageFilename = 'mask';

  /// Standardmäßige relative Position der Maske ([ImageFilterConfig.offset]).
  static const Offset defaultOffset = Offset(0.0, 25);

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    if (filterImage.image == null) return;
    final landmarks = face.landmarks;
    if (landmarks.isEmpty) return;

    // Gesichtsdaten
    final faceBox = fgc.transformBoundingBox(face.boundingBox);
    final faceCenter = faceBox.center;
    final faceWidth = faceBox.width;
    final faceHeight = faceBox.height;

    // Skalierung aus der Config
    final double width = faceWidth * config.scale.scaleX;
    final double height = faceHeight * config.scale.scaleY;

    // Offset relativ zur Gesichtsgröße, rotiert mit Gesicht
    final Offset relativeOffset =
        GeometryService.scaleOffset(config.offset, faceWidth, faceHeight);

    final totalRotation =
        fgc.calculateFaceZRotation(face, extraRotation: config.rotation);

    // Offset rotieren
    final Offset rotatedOffset =
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
    canvas.rotate(totalRotation);
    canvas.translate(-maskRect.center.dx, -maskRect.center.dy);

    // Maske zeichnen
    paintImage(
      canvas: canvas,
      rect: maskRect,
      image: filterImage.image!,
      opacity: config.opacity,
      filterQuality: FilterQuality.high,
    );

    canvas.restore();
  }
}
