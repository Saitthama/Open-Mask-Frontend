
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class ImageService {
  static Future<ui.Image> loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final list = Uint8List.view(data.buffer);
    final codec = await ui.instantiateImageCodec(list);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
