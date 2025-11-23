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

  /// Standarmäßiger Asset-Path ([filterImage.assetPath]).
  static const String defaultAssetPath = 'assets/images/filter/mustache.png';

  /// Standardmäßiger Dateiname des Filter-Bildes ([filterImage.filename]).
  static const String defaultImageFilename = 'mustache';

  /// Standardmäßige relative Position unter der Nase.
  static const Offset defaultOffset = Offset(0.0, 10);

  /// Standardmäßiger Scale.
  static const Scale defaultScale = Scale(0.4, 0.4);

  @override
  void apply(final Face face, final Canvas canvas, final Size canvasSize,
      final Scale scale, final bool isFrontCamera) {
    if (filterImage.image == null) return;

    final double canvasWidth = min(canvasSize.width, canvasSize.height);

    // Beispiel: Nasensteg als Referenzpunkt
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];
    if (noseBase == null) return;

    // Position transformieren
    final double x = isFrontCamera
        ? canvasWidth - noseBase.position.x.toDouble() * scale.scaleX
        : noseBase.position.x.toDouble() * scale.scaleX;
    final double y = noseBase.position.y.toDouble() * scale.scaleY;

    // Rotation berechnen
    final faceRotation =
        (isFrontCamera ? -face.headEulerAngleZ! : face.headEulerAngleZ!) *
            pi /
            180;

    final extraRotation =
        (isFrontCamera ? -config.rotation : config.rotation) * pi / 180;
    final totalRotation = faceRotation + extraRotation;

    // Gesichtsgröße und Offset berechnen
    final faceWidth = face.boundingBox.width * scale.scaleX;
    final faceHeight = face.boundingBox.height * scale.scaleY;

    final offset = Offset((config.offset.dx) / 100 * faceWidth,
        (config.offset.dy) / 100 * faceHeight);
    final rotatedOffset = GeometryService.rotateOffset(offset, totalRotation);

    final filterWidth = faceWidth * config.scale.scaleX;
    final filterHeight = faceHeight * config.scale.scaleY;

    final mustacheRect = Rect.fromCenter(
      center: Offset(x + rotatedOffset.dx, y + rotatedOffset.dy),
      width: filterWidth,
      height: filterHeight,
    );

    canvas.save();

    // Gesichtsrotation (Neigung) + ExtraRotation berechnen
    canvas.translate(mustacheRect.center.dx, mustacheRect.center.dy);
    canvas.rotate(isFrontCamera ? -totalRotation : totalRotation);
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
