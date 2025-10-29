import 'dart:ui' as ui;

import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/filter/configs/image_filter_config.dart';
import 'package:open_mask/filter/templates/filter.dart';

/// Abstrakte Basisklasse für Filter, die ein Bild verwenden (z. B. Bart, Hut, Maske).
abstract class ImageFilter extends Filter {
  ImageFilter(
      {super.id,
      required super.meta,
      required super.type,
      required ImageFilterConfig super.config})
      : _imageFilterConfig = config;

  /// Bildkonfiguration mit spezifischen Eigenschaften wie dem Bildpfad, aber auch allgemeinen Filter-Attributen.
  final ImageFilterConfig _imageFilterConfig;

  /// Liefert die Bildkonfiguration mit spezifischen Eigenschaften wie dem Bildpfad, aber auch allgemeinen Filter-Attributen.
  @override
  ImageFilterConfig get config => _imageFilterConfig;

  /// Geladenes Bild (aus z.B. Asset, DB oder lokaler Bildauswahl).
  ui.Image? image;

  /// Gibt an, ob das Bild gerade geladen wird.
  bool _isLoading = false;

  /// Liefert Attribut, welches aussagt, ob das Bild gerade geladen wird.
  bool get isLoading => _isLoading;

  /// Lädt das Bild (z.B. aus Asset oder vom Server).
  Future<void> load() async {
    _isLoading = true;
    if (config.imagePath != null && config.imagePath!.startsWith('assets')) {
      image = await ImageService.loadImage(config.imagePath!);
    }
    _isLoading = false;
  }
}
