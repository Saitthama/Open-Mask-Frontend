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
      this.image,
      this.mimeType,
      final int? width,
      final int? height})
      : _width = width,
        _height = height;

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory FilterImage.fromJSON(final Map<String, dynamic> json) => FilterImage(
      id: json['id'] as int,
      filename: json['filename'] ?? 'filter_image',
      assetPath: json['assetPath'],
      imageUrl: json['imageUrl'],
      width: json['width'] as int,
      height: json['height'] as int);

  /// Eindeutige Datenbank-ID des Filters.
  final int? id;

  /// Der Name des Bildes, welcher beim Speichern als Dateiname (ohne Erweiterung) dient.
  String filename;

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
  /// Liefert true zurück, wenn das Bild erfolgreich geladen werden konnte.
  /// [failedToLoad] wird auf true gesetzt, falls das Laden fehlgeschlagen ist.
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
      _isLoading = false;
      _failedToLoad = true;
      return !_failedToLoad;
    }

    _failedToLoad = image == null;

    _isLoading = false;
    return image != null;
  }

  /// Lädt das Bild aus dem Internet über die URL. <br>
  /// Liefert true zurück, wenn das Bild erfolgreich heruntergeladen wurde.
  /// [failedToLoad] wird auf true gesetzt, falls das Laden fehlgeschlagen ist.
  Future<bool> loadFromURL() async {
    if (imageUrl == null || isLoading) {
      return false;
    }
    _isLoading = true;
    rawData = await ImageService.loadImageFromURL(imageUrl!);
    if (rawData != null) {
      image = await ImageService.uint8ListToUiImage(rawData!);
    } else {
      _isLoading = false;
      _failedToLoad = true;
      return !_failedToLoad;
    }

    _failedToLoad = image == null;

    _isLoading = false;
    return !_failedToLoad;
  }

  /// Versucht das Bild aus der URL ([loadFromURL]) und dem Asset ([loadFromAsset]) zu laden, je nachdem was angegeben wurde. <br>
  /// Falls beides angegeben wurde, wird das Asset zuerst versucht zu laden). <br>
  /// [failedToLoad] wird auf true gesetzt, falls das Laden fehlgeschlagen ist.
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

  /// Gibt die verwendete Ressourcen für das Bild frei.
  void dispose() {
    image?.dispose();
    image = null;
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

  /// Erstellt eine unabhängige Kopie des der [FilterImage]-Instanz.
  FilterImage fork() {
    return FilterImage(
        id: id,
        filename: filename,
        assetPath: assetPath,
        imageUrl: imageUrl,
        image: image?.clone());
  }
}
