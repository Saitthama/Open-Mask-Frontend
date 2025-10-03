import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/src/face_detector.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/filter/configs/mustache_config.dart';
import 'package:open_mask/filter/i_filter.dart';

import '../../data/services/image_service.dart';

class MustacheFilter implements IFilter {
  @override
  MustacheConfig config;

  ui.Image? _image;
  bool isLoading = false;

  MustacheFilter(this.config);

  Future<void> load() async {
    isLoading = true;
    _image = await ImageService.loadImage(config.assetPath);
    isLoading = false;
  }

  @override
  void apply(Face face, Canvas canvas, Size canvasSize, Scale scale,
      bool isFrontCamera) {
    if (_image == null) {
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

    double offsetY = config.offsetY;
    double filterWidth = face.boundingBox.width * config.relativeWidth;
    double filterHeight = face.boundingBox.height * config.relativeHeight;

    final mustacheRect = Rect.fromCenter(
      center: Offset(x, y + offsetY),
      width: filterWidth, // Größe anpassen
      height: filterHeight,
    );

    paintImage(canvas: canvas, rect: mustacheRect, image: _image!);
  }

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = config.toJSON();
    json['type'] = 'mustache';
    return json;
  }

  factory MustacheFilter.fromJSON(Map<String, dynamic> json) =>
      MustacheFilter(MustacheConfig.fromJSON(json));
}
