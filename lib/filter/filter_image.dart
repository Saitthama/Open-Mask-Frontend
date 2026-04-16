import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:open_mask/data/model/image_mime_type.dart';
import 'package:open_mask/data/services/image_service.dart';

/// Klasse zum Speichern eines Filter-Bildes, welches das Bild selbst mit dazugehörigen Metadaten enthält.
class FilterImage {
  /// Standard-Konstruktor.
  FilterImage({
    this.id,
    required this.filename,
    this.assetPath,
    this.imageUrl,
    final Uint8List? rawData,
    final int? width,
    final int? height,
    final ImageMimeType? mimeType,
  })  : _width = width,
        _height = height {
    this.rawData = rawData;
    if (mimeType != null) {
      _mimeType = mimeType;
    }
  }

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory FilterImage.fromJSON(final Map<String, dynamic> json) => FilterImage(
      id: json['id'] as int?,
      filename: json['filename'] ?? 'filter_image',
      assetPath: json['assetPath'],
      imageUrl: json['imageUrl'],
      mimeType: json['mimeType'] == null
          ? null
          : mimeTypeFromString(json['mimeType']),
      width: json['width'] as int?,
      height: json['height'] as int?);

  /// Eindeutige Datenbank-ID des Filters.
  final int? id;

  /// Der Name des Bildes, welcher beim Speichern als Dateiname (ohne Erweiterung) dient.
  String filename;

  /// MIME-Typ des Bildes.
  ImageMimeType? _mimeType;

  /// MIME-Typ des Bildes.
  ImageMimeType? get mimeType => _mimeType;

  /// Wenn das Bild ein lokales Asset ist.
  final String? assetPath;

  /// Falls das Bild aus dem Internet kommt.
  final String? imageUrl;

  /// Geladenes Bild (aus Asset, DB, URL oder lokaler Bildauswahl).
  ui.Image? image;

  Widget? get imageAsWidget {
    final rawData = this.rawData;
    if (rawData != null) {
      return Image.memory(rawData);
    }
    return null;
  }

  /// Geladene Rohdaten des Bildes ([image]) (aus Asset, DB, URL oder lokaler Bildauswahl).
  Uint8List? _rawData;

  /// Geladene Rohdaten des Bildes ([image]) (aus Asset, DB, URL oder lokaler Bildauswahl).
  Uint8List? get rawData => _rawData;

  /// Geladene Rohdaten des Bildes ([image]) (aus Asset, DB, URL oder lokaler Bildauswahl).
  set rawData(final Uint8List? value) {
    _rawData = value;
    _mimeType = value == null ? null : detectMimeType(value);
  }

  /// Breite des Bildes in Pixel.
  int? _width;

  /// Breite des Bildes in Pixel. Liefert die aktuelle Breite des Bildes [image] (oder beim Fehlen dessens den bei der Initialisierung zugewiesenen Wert).
  int? get width => image?.width ?? _width;

  /// Höhe des Bildes in Pixel.
  int? _height;

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

  /// Skaliert das Bild auf die neue [size]. <p>
  /// Das Seitenverhältnis wird beibehalten und die kleinere Seite (Breite/Höhe) wird auf die entsprechende gerundete [size] gesetzt. <br>
  /// Falls die [size] nicht gegeben ist, wird die intern gesetzte Größe verwendet. <br>
  /// Das Bild wird mit PNG neu kodiert, wenn erfolgreich.</p
  Future<void> resize(final Size? size) async {
    _width = size?.width.round() ?? _width ?? _height;
    _height = size?.height.round() ?? _height ?? _width;
    if (_width == null) {
      return;
    }

    if (rawData == null) {
      await loadRawData(); // ruft resize intern wieder auf
      return;
    }

    final newData = await ImageService.resizeImage(
        rawData!, Size(_width!.toDouble(), _height!.toDouble()));
    if (newData == rawData) {
      return;
    }
    rawData = newData;
    if (image != null) {
      await loadFromRawData();
    }
  }

  /// Lädt das Bild aus den Rohdaten. <br>
  /// Liefert true zurück, wenn das Bild erfolgreich geladen werden konnte.
  /// [failedToLoad] wird auf true gesetzt, falls das Laden fehlgeschlagen ist.
  Future<bool> loadFromRawData() async {
    if (rawData == null || isLoading) {
      return false;
    }
    _isLoading = true;

    image = await ImageService.uint8ListToUiImage(rawData!);
    _failedToLoad = false;
    _isLoading = false;
    return true;
  }

  /// Versucht das Bild aus der URL ([loadFromURL]) und dem Asset ([loadFromAsset]) zu laden, je nachdem was angegeben wurde. <br>
  /// Falls beides angegeben wurde, wird das Asset zuerst versucht zu laden). <br>
  /// [failedToLoad] wird auf true gesetzt, falls das Laden fehlgeschlagen ist. <br>
  /// Gibt true zurück, falls der Filter bereits geladen war, oder erfolgreich geladen wurde.
  Future<bool> load() async {
    if (isLoading) {
      return false;
    }
    if (rawData != null && image != null) {
      return true;
    }
    if (rawData != null) {
      final bool success = await loadFromRawData();
      if (success) return success;
    }
    await loadRawData();
    _isLoading = true;
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

  /// Lädt die Rohdaten aus dem Asset oder der URL, falls diese noch nicht vorhanden sind. <br>
  /// Falls beides angegeben wurde, wird das Asset zuerst versucht zu laden). <br>
  /// [failedToLoad] wird auf true gesetzt, falls das Laden fehlgeschlagen ist.
  Future<bool> loadRawData() async {
    if (rawData != null) {
      await resize(null);
      return true;
    }
    if (isLoading) {
      return false;
    }
    _isLoading = true;
    if (assetPath != null) {
      rawData = await ImageService.loadImageFromAsset(assetPath!);
    }
    if (imageUrl != null) {
      rawData ??= await ImageService.loadImageFromURL(imageUrl!);
    }
    if (rawData != null) {
      await resize(null);
    }

    _isLoading = false;
    _failedToLoad = rawData == null;
    return rawData != null;
  }

  /// Gibt die verwendeten Ressourcen für das Bild frei.
  void dispose() {
    image?.dispose();
    image = null;
    if (imageUrl != null || assetPath != null) {
      rawData = null;
    }
  }

  /// Methode zur JSON‑Serialisierung, welche den Filter in ein JSON-Objekt umwandelt.
  Map<String, dynamic> toJSON() => {
        if (id != null) 'id': id,
        'filename': filename,
        if (mimeType != null) 'mimeType': mimeType?.mimeString,
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
        rawData: rawData);
  }
}
