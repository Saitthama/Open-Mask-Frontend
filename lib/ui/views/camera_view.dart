import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/screens/filter_image_processing_screen.dart';
import 'package:open_mask/ui/screens/gallery_screen.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/views/face_markings_view.dart';
import 'package:open_mask/ui/views/filter_view.dart';
import 'package:open_mask/ui/widgets/camera_shutter_button.dart';
import 'package:open_mask/ui/widgets/face_markings_list_tile.dart';
import 'package:provider/provider.dart';

/// View, welches die UI für die Kameraanzeige selbst enthält und für [CameraScreen] bereitstellt. Nutzt [CameraViewModel] für Logik.
class CameraView extends StatelessWidget {
  /// Standard-Konstruktor.
  const CameraView({super.key, required this.navigateTo});

  /// Funktion zum Pushen von neuen Seiten, welche vom [CameraScreen] verwaltet wird.
  final Function(String route) navigateTo;

  @override
  Widget build(final BuildContext context) {
    final CameraViewModel vm = context.watch<CameraViewModel>();

    final previewSize = vm.cameraService.cameraController?.value.previewSize;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double?
        aspectRatio; // dient zur Skalierung der Preview und Painter auf die gleiche Größe
    if (previewSize != null) {
      aspectRatio = isPortrait
          ? previewSize.height / previewSize.width
          : previewSize.width / previewSize.height;
    }

    final preview = Center(
      child: (aspectRatio == null ||
              vm.changingCamera ||
              !vm.cameraService.cameraLive)
          ? const CircularProgressIndicator()
          : AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(vm.cameraService.cameraController!),
                  FaceMarkingsView(
                    showMarkings: vm.showMarkings,
                    showFaceBox: vm.showFaceBox,
                    showLandmarks: vm.showLandmarks,
                    showContours: vm.showContours,
                  ),
                  if (vm.filter != null && vm.filterActive)
                    FilterView(vm.filter!)
                ],
              ),
            ),
    );

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          preview,

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
                    onTap: () => _openOtherOptionsSelection(context, vm),
                    child: Icon(Icons.photo_library,
                        color: ButtonTheme.of(context).colorScheme?.primary,
                        size: 28)),

                // TODO: ausgewählten Filter anzeigen & Filter auswählen
                // Auslöse-Button
                CameraShutterButton(
                    onTap: vm.takePicture, onLongPress: vm.switchFilterActive),

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

  /// Öffnet eine Auswahl für weitere Optionen wie zur Öffnung der Galerie von gemachten Fotos, zum Ein- und Ausschalten bestimmter Funktionen, etc.
  void _openOtherOptionsSelection(
      final BuildContext context, final CameraViewModel vm) {
    ThemeData theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (final _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo,
                color: theme.iconTheme.color,
              ),
              title: const Text('App-Galerie anzeigen'),
              onTap: () => navigateTo(
                  '${CameraScreen.routePath}${GalleryScreen.routePath}'),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_filter,
                color: theme.iconTheme.color,
              ),
              title: const Text('Filter auswählen'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.filter,
                color: theme.iconTheme.color,
              ),
              title: const Text('Filter-Bildverarbeitung öffnen'),
              enabled: vm.filter != null,
              onTap: () => navigateTo(
                  '${CameraScreen.routePath}${FilterImageProcessingScreen.routePath}'),
            ),
            FaceMarkingsListTile(viewModel: vm),
          ],
        );
      },
    );
  }
}
