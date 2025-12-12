import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/ui/screens/gallery_screen.dart';
import 'package:open_mask/ui/views/gallery_view.dart';

/// View-Model, welches die Logik für den [GalleryScreen] und das [GalleryView] hält.
class GalleryViewModel extends ChangeNotifier {
  /// Die Liste der Fotos in der App-Galerie.
  /// Wird asynchron in [initialize] geladen und ist standardmäßig eine leere Liste.
  List<File> _photos = [];

  /// Die Liste der Fotos in der App-Galerie.
  List<File> get photos => _photos;

  /// Initialisiert das View-Model und die nötigen Attribute wie z.B. [photos].
  Future<void> initialize() async {
    _photos = await ImageService.loadLocalPhotos();
    notifyListeners();
  }
}
