import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';

/// Klasse zum Speichern eines Filter-Bildes, welches das Bild selbst mit dazugehörigen Metadaten enthält.
class FilterImage {
  /// Standard-Konstruktor.
  FilterImage(
      {this.id,
      required this.filename,
      this.assetPath,
      this.imageUrl,
      final int? width,
      final int? height})
      : _width = width,
        _height = height;

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory FilterImage.fromJSON(final Map<String, dynamic> json) => FilterImage(
      id: int.tryParse(json['id']),
      filename: json['filename'] ?? 'filter_image',
      assetPath: json['assetPath'],
      imageUrl: json['imageUrl'],
      width: int.tryParse(json['width']),
      height: int.tryParse(json['height']));

  /// Eindeutige Datenbank-ID des Filters.
  final int? id;

  /// Der Name des Bildes, welcher beim Speichern als Dateiname dient.
  final String filename;

  /// Wenn das Bild ein lokales Asset ist.
  String? assetPath;

  /// Falls das Bild aus dem Internet kommt.
  String? imageUrl;

  /// Geladenes Bild (aus Asset, DB, URL oder lokaler Bildauswahl).
  ui.Image? image;

  /// Geladene Rohdaten des Bildes ([image]) (aus Asset, DB, URL oder lokaler Bildauswahl).
  Uint8List? rawData;

  /// Breite des Bildes in Pixel.
  final int? _width;

  /// Breite des Bildes in Pixel. Liefert die aktuelle Breite des Bildes [image] (oder beim Fehlen dessens den bei der Initialisierung zugewiesenen Wert).
  int? get width => image?.width ?? _width;

  /// Höhe des Bildes in Pixel.
  final int? _height;

  /// Höhe des Bildes in Pixel. Liefert die aktuelle Höhe des Bildes [image] (oder beim Fehlen dessens den bei der Initialisierung zugewiesenen Wert).
  int? get height => image?.height ?? _height;

  /// Gibt an, ob das Bild gerade geladen wird.
  bool _isLoading = false;

  /// Liefert Attribut, welches aussagt, ob das Bild gerade geladen wird.
  bool get isLoading => _isLoading;

  /// Lädt das Bild aus dem Asset.
  Future<void> loadFromAsset() async {
    if (assetPath != null) {
      _isLoading = true;
      rawData = await ImageService.loadImageFromAsset(assetPath!);
      if (rawData != null) {
        image = await ImageService.uint8ListToUiImage(rawData!);
      } else {
        SnackBarService.showMessage(
            'Asset ($assetPath) konnte nicht geladen werden!');
      }
      _isLoading = false;
    }
  }

  /// Lädt das Bild aus dem Internet über die URL.
  Future<void> loadFromURL() async {
    if (imageUrl != null) {
      _isLoading = true;
      rawData = await ImageService.loadImageFromURL(imageUrl!);
      if (rawData != null) {
        image = await ImageService.uint8ListToUiImage(rawData!);
      } else {
        SnackBarService.showMessage(
            'Bild ($imageUrl) konnte nicht geladen werden!');
      }
      _isLoading = false;
    }
  }

  /// Versucht das Bild aus der URL ([loadFromURL]) und dem Asset ([loadFromAsset]) zu laden, je nachdem was angegeben wurde (falls beides angegeben wurde, wird das Asset geladen).
  Future<void> load() async {
    if (imageUrl != null && assetPath != null) {
      await loadFromAsset();
      return;
    }

    await loadFromURL();
    await loadFromAsset();
  }

  /// Methode zur JSON‑Serialisierung, welche den Filter in ein JSON-Objekt umwandelt.
  Map<String, dynamic> toJSON() => {
        if (id != null) 'id': id,
        'filename': filename,
        if (assetPath != null) 'assetPath': assetPath,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'width': width,
        'height': height,
      };
}
