import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/filter/configs/image_filter_config.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/templates/image_filter.dart';

/// Filter, der einen Schnurrbart (Mustache) darstellt.
/// Bildfilter, der relativ zur Nase positioniert wird.
class MustacheFilter extends ImageFilter {
  MustacheFilter({super.id, required super.meta, required super.config})
      : super(type: FilterType.mustache);

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory MustacheFilter.fromJSON(final Map<String, dynamic> json) {
    Map<String, dynamic> configJson = json['config'] ?? {};
    configJson.putIfAbsent('assetPath', () => standardImagePath);
    configJson.putIfAbsent('scaleX', () => standardScale.scaleX);
    configJson.putIfAbsent('scaleY', () => standardScale.scaleY);
    configJson.putIfAbsent('offsetX', () => standardOffset.dx);
    configJson.putIfAbsent('offsetY', () => standardOffset.dy);

    ImageFilterConfig imageFilterConfig =
        ImageFilterConfig.fromJSON(configJson);

    MustacheFilter mustacheFilter = MustacheFilter(
        id: json['id'],
        meta: FilterMeta.fromJson(json['meta']),
        config: imageFilterConfig);

    return mustacheFilter;
  }

  /// Standarmäßiger Asset-Path.
  static const String standardImagePath = 'assets/images/mustache.png';

  /// Standardmäßige relative Position unter der Nase.
  static const Offset standardOffset = Offset(0.0, 20);

  /// Standardmäßiger Scale.
  static const Scale standardScale = Scale(0.4, 0.4);

  @override
  void apply(final Face face, final Canvas canvas, final Size canvasSize,
      final Scale scale, final bool isFrontCamera) {
    canvas.save();

    if (image == null) {
      if (!isLoading) {
        load();
      }
      return;
    }

    final double canvasWidth = min(canvasSize.width, canvasSize.height);

    // Beispiel: Nasensteg als Referenzpunkt
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];
    if (noseBase == null) return;

    // Position transformieren
    final double x = isFrontCamera
        ? canvasWidth - noseBase.position.x.toDouble() * scale.scaleX
        : noseBase.position.x.toDouble() * scale.scaleX;
    final double y = noseBase.position.y.toDouble() * scale.scaleY;

    double offsetX = config.offset.dx;
    double offsetY = config.offset.dy;
    double filterWidth = face.boundingBox.width * config.scale.scaleX;
    double filterHeight = face.boundingBox.height * config.scale.scaleY;

    final mustacheRect = Rect.fromCenter(
      center: Offset(x + offsetX, y + offsetY),
      width: filterWidth,
      height: filterHeight,
    );

    canvas.rotate(config.rotation);
    paintImage(canvas: canvas, rect: mustacheRect, image: image!);

    canvas.restore();
  }
}
