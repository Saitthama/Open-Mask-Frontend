import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/ui/screens/gallery_screen.dart';
import 'package:open_mask/ui/views/gallery_view.dart';
import 'package:synchronized/synchronized.dart';

/// View-Model, welches die Logik für den [GalleryScreen] und das [GalleryView] hält.
class GalleryViewModel extends ChangeNotifier {
  /// Die Liste der Fotos in der App-Galerie.
  /// Wird asynchron in [initialize] geladen und ist standardmäßig eine leere Liste.
  List<File> _elements = [];

  /// Die Liste der Elemente (wie Photos) in der App-Galerie.
  List<File> get elements => _elements;

  /// Lock-Objekt, welches dazu dient, zu verhindern,
  /// dass Elemente aus der App-Galerie gleichzeitig ins Open-Mask-Album gespeichert
  /// und aus der App-Galerie gelöscht werden.
  final Lock _saveDeleteLock = Lock();

  /// Initialisiert das View-Model und die nötigen Attribute wie [elements].
  Future<void> initialize() async {
    _elements = await ImageService.loadLocalPhotos();
    notifyListeners();
  }

  /// Speichert alle Elemente aus der App-Galerie in das Open-Mask-Album der Galerie.
  /// Gibt zurück, ob alle Elemente erfolgreich gespeichert wurden.
  Future<bool> saveAll() async {
    bool success = true;
    for (int i = 0; i < _elements.length; i++) {
      success = success && await saveElementWithIndex(i);
    }
    return success;
  }

  /// Speichert das Element (z.B. Photo) mit dem angegebenen Index aus [elements] in das Open-Mask-Album der Galerie.
  /// Gibt zurück, ob das Element erfolgreich gespeichert wurde.
  Future<bool> saveElementWithIndex(final int index) async {
    bool success = false;
    await _saveDeleteLock.synchronized(() async {
      if (index < 0 || index >= _elements.length) {
        return;
      }

      success = await ImageService.saveImageFileToGallery(_elements[index]);
    });
    notifyListeners();
    return success;
  }

  /// Löscht alle Elemente aus der App-Galerie.
  /// Gibt zurück, ob alle Elemente erfolgreich gelöscht wurden.
  Future<bool> deleteAll() async {
    bool success = true;
    while (elements.isNotEmpty && success) {
      success = success && await deleteElementWithIndex(0);
    }
    return success;
  }

  /// Löscht das Element mit dem angegebenen Index aus [elements] aus der App-Galerie.
  Future<bool> deleteElementWithIndex(final int index) async {
    bool success = false;
    await _saveDeleteLock.synchronized(() async {
      if (index < 0 || index >= _elements.length) {
        return;
      }

      success =
          await ImageService.deleteImageFileFromAppGallery(_elements[index]);
      if (success) _elements.removeAt(index);
    });
    notifyListeners();
    return success;
  }
}
