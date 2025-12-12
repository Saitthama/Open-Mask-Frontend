import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/view_models/gallery_view_model.dart';
import 'package:open_mask/ui/views/gallery_view.dart';
import 'package:provider/provider.dart';

/// Seite, die die App-Galerie enthält. Die UI ist im [GalleryView] und die Logik im [GalleryViewModel].
/// <ul>
///   <li>Enthält Routeninformationen über die Seite ([routePath]).</li>
///   <li>Verwaltet das zugehörige [GalleryViewModel] und [GalleryView].</li>
/// </ul>
class GalleryScreen extends StatelessWidget {
  /// Standard-Konstruktor.
  const GalleryScreen({super.key});

  /// Route zu der Seite, über die diese als Subseite des [CameraScreen] erreicht werden kann.
  static const routePath = '/gallery';

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider(
        create: (final _) => GalleryViewModel()..initialize(),
        child: const GalleryView());
  }
}
