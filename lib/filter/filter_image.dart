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

  /// MIME-Typ des Bildes, z.B. "image/png".
  String? mimeType;

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

  /// Wird auf [true] gesetzt, wenn erfolglos versucht wurde, das Bild zu laden. <br>
  /// Wird wieder auf [false] zurückgesetzt, wenn ein Bild erfolgreich geladen wurde.
  bool _failedToLoad = false;

  /// Gibt an, ob erfolglos versucht wurde, das Bild zu laden.
  bool get failedToLoad => _failedToLoad;

  /// Lädt das Bild aus dem Asset. <br>
  /// Liefert [true] zurück, wenn das Bild erfolgreich geladen werden konnte.
  /// [failedToLoad] wird auf [true] gesetzt, falls das Laden fehlgeschlagen ist.
  Future<bool> loadFromAsset() async {
    if (assetPath == null || isLoading) {
      return false;
    }

    _isLoading = true;
    rawData = await ImageService.loadImageFromAsset(assetPath!);
    if (rawData != null) {
      image = await ImageService.uint8ListToUiImage(rawData!);
    } else {
      SnackBarService.showMessage(
          'Asset ($assetPath) konnte nicht geladen werden!');
    }

    _failedToLoad = image == null;

    _isLoading = false;
    return image != null;
  }

  /// Lädt das Bild aus dem Internet über die URL. <br>
  /// Liefert [true] zurück, wenn das Bild erfolgreich heruntergeladen wurde.
  /// [failedToLoad] wird auf [true] gesetzt, falls das Laden fehlgeschlagen ist.
  Future<bool> loadFromURL() async {
    if (imageUrl == null || isLoading) {
      return false;
    }
    _isLoading = true;
    rawData = await ImageService.loadImageFromURL(imageUrl!);
    if (rawData != null) {
      image = await ImageService.uint8ListToUiImage(rawData!);
    }

    _failedToLoad = image == null;

    _isLoading = false;
    return !_failedToLoad;
  }

  /// Versucht das Bild aus der URL ([loadFromURL]) und dem Asset ([loadFromAsset]) zu laden, je nachdem was angegeben wurde. <br>
  /// Falls beides angegeben wurde, wird das Asset zuerst versucht zu laden). <br>
  /// [failedToLoad] wird auf [true] gesetzt, falls das Laden fehlgeschlagen ist.
  Future<bool> load() async {
    if (isLoading) {
      return false;
    }
    bool loaded = false;
    loaded = await loadFromAsset();
    if (loaded == false) {
      loaded = await loadFromURL();
    }
    _failedToLoad = !loaded;
    return loaded;
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
