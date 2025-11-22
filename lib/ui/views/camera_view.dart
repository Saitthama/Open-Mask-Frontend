import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/views/face_markings_view.dart';
import 'package:open_mask/ui/views/filter_view.dart';
import 'package:open_mask/ui/widgets/camera_shutter_button.dart';
import 'package:open_mask/ui/widgets/gallery_popup.dart';
import 'package:provider/provider.dart';

/// View, welches die UI für die Kameraanzeige selbst enthält und für [CameraScreen] bereitstellt. Nutzt [CameraViewModel] für Logik.
class CameraView extends StatelessWidget {
  /// Standard-Konstruktor.
  const CameraView({super.key});

  @override
  Widget build(final BuildContext context) {
    final CameraViewModel vm = context.watch<CameraViewModel>();

    if (!vm.initializedAndLive) {
      return const Center(child: CircularProgressIndicator());
    }

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: (vm.changingCamera || !vm.cameraService.cameraLive)
                ? const CircularProgressIndicator()
                : CameraPreview(vm.cameraService.cameraController!),
          ),
          Center(
            child: FaceMarkingsView(
                showMarkings: vm.showMarkings, showLandmarks: vm.showLandmarks),
          ),
          if (vm.filter != null) Center(child: FilterView(vm.filter!)),

          // --- Buttons Overlay ---
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Linker Button
                GestureDetector(
                    onTap: () => _openGalleryFilterSelection(context, vm),
                    child: Icon(Icons.photo_library,
                        color: ButtonTheme.of(context).colorScheme?.primary,
                        size: 28)),

                // TODO: ausgewählten Filter anzeigen
                // Auslöse-Button
                CameraShutterButton(onTap: vm.takePicture),

                // Rechter Button
                GestureDetector(
                    onTap: vm.switchLiveCamera,
                    child: Icon(Icons.cameraswitch,
                        color: ButtonTheme.of(context).colorScheme?.primary,
                        size: 28)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Filterauswahl und Fotogalerie einbinden
  /// Öffnet eine Auswahl, mit der man entweder zur Filterauswahl oder zu den gemachten Fotos weiter navigieren kann.
  void _openGalleryFilterSelection(
      final BuildContext context, final CameraViewModel vm) {
    showModalBottomSheet(
      context: context,
      builder: (final _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Fotogalerie anzeigen'),
              onTap: () => _openGalleryPopup(context),
            ),
            ListTile(
              leading: const Icon(Icons.photo_filter),
              title: const Text('Filter auswählen'),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  /// Lädt die Photos mit [ImageService.loadLocalPhotos] und öffnet das Galerie-Popup ([GalleryPopup]).
  Future<void> _openGalleryPopup(final BuildContext context) async {
    final photos = await ImageService.loadLocalPhotos();
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      // Hintergrund abdunkeln, Kamera bleibt sichtbar
      builder: (final _) => Center(
        child: GalleryPopup(photos: photos),
      ),
    );
  }
}
