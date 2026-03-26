import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/screens/filter_image_processing_screen.dart';
import 'package:open_mask/ui/screens/gallery_screen.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/views/face_markings_view.dart';
import 'package:open_mask/ui/views/filter_view.dart';
import 'package:open_mask/ui/widgets/camera_shutter_button.dart';
import 'package:open_mask/ui/widgets/face_markings_list_tile.dart';
import 'package:open_mask/ui/widgets/filter_option_list_tile.dart';
import 'package:open_mask/ui/widgets/filter_selection_popup.dart';
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

    final faceDetectionService = Provider.of<FaceDetectionService>(context);
    final cameraService = Provider.of<CameraService>(context);
    final bool isFrontCamera =
        cameraService.cameraController?.description.lensDirection ==
            CameraLensDirection.front;

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
                    faces: faceDetectionService.faces,
                    processedSize: faceDetectionService.processedSize,
                    isFrontCamera: isFrontCamera,
                    showMarkings: vm.showMarkings,
                    showFaceBox: vm.showFaceBox,
                    showLandmarks: vm.showLandmarks,
                    showContours: vm.showContours,
                  ),
                  if (vm.filter != null && vm.filterActive)
                    FilterView(
                      vm.filter!,
                      faces: faceDetectionService.faces,
                      processedSize: faceDetectionService.processedSize,
                      isFrontCamera: isFrontCamera,
                    )
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
                  onTap: vm.takePicture,
                  onLongPress: () {
                    if (!vm.filterActive) {
                      vm.switchFilterActive();
                    }
                    showDialog(
                        context: context,
                        barrierColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withAlpha(180),
                        builder: (final context) {
                          return const FilterSelectionPopup();
                        });
                  },
                  child: FilterStore.instance.selectedFilter == null
                      ? null
                      : Opacity(
                          opacity: vm.filterActive ? 1.0 : 0.4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: SizedBox(
                              width: 45,
                              height: 45,
                              child: FittedBox(
                                child: (FilterStore.instance.selectedFilter
                                        as Filter)
                                    .meta
                                    .icon,
                              ),
                            ),
                          ),
                        ),
                ),

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
            FilterOptionListTile(viewModel: vm),
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
