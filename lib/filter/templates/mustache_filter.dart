import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/geometry_service.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/image_filter.dart';

/// Filter, der einen Schnurrbart (Mustache) darstellt.
/// Bildfilter, der relativ zur Nase positioniert wird.
class MustacheFilter extends ImageFilter {
  /// Standard-Konstruktor.
  MustacheFilter(
      {super.id,
      required super.meta,
      required super.config,
      required super.filterImage})
      : super(type: FilterType.mustache);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory MustacheFilter.fromJSON(final Map<String, dynamic> json) {
    Map<String, dynamic> configJson = json['config'] ?? {};
    configJson.putIfAbsent('scaleX', () => defaultScale.scaleX);
    configJson.putIfAbsent('scaleY', () => defaultScale.scaleY);
    configJson.putIfAbsent('offsetX', () => defaultOffset.dx);
    configJson.putIfAbsent('offsetY', () => defaultOffset.dy);

    Map<String, dynamic> filterImageJson = json['filterImage'] ?? {};
    filterImageJson.putIfAbsent('assetPath', () => defaultAssetPath);
    filterImageJson.putIfAbsent('filename', () => defaultImageFilename);

    FilterConfig filterConfig = FilterConfig.fromJSON(configJson);

    MustacheFilter mustacheFilter = MustacheFilter(
        id: int.tryParse(json['id']),
        meta: FilterMeta.fromJson(json['meta']),
        config: filterConfig,
        filterImage: FilterImage.fromJSON(filterImageJson));

    return mustacheFilter;
  }

  /// Standarmäßiger Asset-Path ([FilterImage.assetPath]).
  static const String defaultAssetPath = 'assets/images/filter/mustache.png';

  /// Standardmäßiger Dateiname des Filter-Bildes ([FilterImage.filename]).
  static const String defaultImageFilename = 'mustache';

  /// Standardmäßige relative Position unter der Nase ([ImageFilterConfig.offset]).
  static const Offset defaultOffset = Offset(0.0, 10);

  /// Standardmäßiger Scale.
  static const Scale defaultScale = Scale(0.4, 0.4);

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    if (filterImage.image == null) return;

    // Beispiel: Nasensteg als Referenzpunkt
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];
    if (noseBase == null) return;

    // Position transformieren
    final Offset noseBaseOffset = fgc.transformPoint(noseBase.position);

    // Rotation berechnen
    final totalRotation =
        fgc.calculateFaceZRotation(face, extraRotation: config.rotation);

    // Gesichtsgröße und Offset berechnen
    final Size faceSize = fgc.calculateDynamicFaceSize(face);

    final Offset relativeOffset = GeometryService.scaleOffset(
        config.offset, faceSize.width, faceSize.height);
    final rotatedOffset =
        GeometryService.rotateOffset(relativeOffset, totalRotation);

    final filterWidth = faceSize.width * config.scale.scaleX;
    final filterHeight = faceSize.height * config.scale.scaleY;

    final mustacheRect = Rect.fromCenter(
      center: Offset(noseBaseOffset.dx + rotatedOffset.dx,
          noseBaseOffset.dy + rotatedOffset.dy),
      width: filterWidth,
      height: filterHeight,
    );

    canvas.save();

    // Gesichtsrotation (Neigung) + ExtraRotation berechnen
    canvas.translate(mustacheRect.center.dx, mustacheRect.center.dy);
    canvas.rotate(totalRotation);
    canvas.translate(-mustacheRect.center.dx, -mustacheRect.center.dy);

    paintImage(
        canvas: canvas,
        rect: mustacheRect,
        image: filterImage.image!,
        opacity: config.opacity,
        filterQuality: FilterQuality.high);

    canvas.restore();
  }
}
