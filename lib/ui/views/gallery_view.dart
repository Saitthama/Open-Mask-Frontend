import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/ui/view_models/gallery_view_model.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';
import 'package:open_mask/ui/widgets/close_save_header.dart';
import 'package:open_mask/ui/widgets/text_close_button.dart';
import 'package:provider/provider.dart';

/// View, welches Bilder in einer Galerie anzeigt.
class GalleryView extends StatelessWidget {
  /// Standard-Konstruktor.
  const GalleryView({super.key});

  /// Öffnet eine Nahansicht eines Photos.
  void _viewPhoto(final BuildContext context, final GalleryViewModel viewModel,
      final int index) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: theme.colorScheme.surface.withAlpha(180),
      builder: (final context) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface.withAlpha(220),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
                border: BoxBorder.all(
                    color: theme.colorScheme.onSurface.withAlpha(220)),
                borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Row(
                    children: [
                      IconButton(
                          padding: const EdgeInsets.all(0),
                          iconSize: 50,
                          onPressed: () async {
                            final bool success =
                                await viewModel.deleteElementWithIndex(index);
                            if (success) {
                              SnackBarService.showMessage(
                                  '${index + 1}. Bild gelöscht',
                                  duration: const Duration(seconds: 1));
                            } else {
                              SnackBarService.showMessage(
                                  'Fehler beim Löschen des ${index + 1}. Bildes!');
                            }
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                          icon: const Icon(Icons.delete_rounded)),
                      Expanded(child: Container()),
                      IconButton(
                          padding: const EdgeInsets.all(4),
                          iconSize: 50,
                          onPressed: () async {
                            final bool success =
                                await viewModel.saveElementWithIndex(index);
                            if (success) {
                              SnackBarService.showMessage(
                                  '${index + 1}. Bild gespeichert',
                                  duration: const Duration(seconds: 1));
                            }
                          },
                          icon: const Icon(Icons.save_rounded)),
                    ],
                  ),
                  InteractiveViewer(
                    maxScale: 10,
                    minScale: 1,
                    child: Image.file(viewModel.elements[index]),
                  ),
                  const TextCloseButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Baut ein Photo-Element für die Galerie.
  Widget _buildPhotoItem(final BuildContext context,
      final GalleryViewModel viewModel, final int index) {
    return GestureDetector(
      onTap: () => _viewPhoto(context, viewModel, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(viewModel.elements[index], fit: BoxFit.cover),
      ),
    );
  }

  /// Zeigt einen Dialog, der nach einer Bestätigung zum Löschen aller Elemente fragt.
  void _showDeleteAllDialog(
      final BuildContext context, final GalleryViewModel viewModel) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: theme.colorScheme.surface.withAlpha(180),
      builder: (final context) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface.withAlpha(220),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
                border: BoxBorder.all(
                    color: theme.colorScheme.onSurface.withAlpha(220)),
                borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  const Text(
                    'Wirklich alle Elemente aus der App-Galerie löschen?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: viewModel.elements.isEmpty
                            ? null
                            : () async {
                                final bool success =
                                    await viewModel.deleteAll();
                                if (success) {
                                  SnackBarService.showMessage(
                                      'Alle Elemente erfolgreich gelöscht',
                                      duration: const Duration(seconds: 2));
                                  if (context.mounted) context.pop();
                                } else {
                                  SnackBarService.showMessage(
                                      'Fehler beim Löschen der Elemente!');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Row(
                          // Stretch
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 5.0,
                          children: [
                            Icon(Icons.delete_rounded,
                                color: viewModel.elements.isEmpty
                                    ? Colors.grey
                                    : Colors.white),
                            Text('Löschen',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: viewModel.elements.isEmpty
                                        ? Colors.grey
                                        : Colors.white)),
                          ],
                        ),
                      ),
                      BlueTextButton(
                        'Abbrechen',
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    final viewModel = context.watch<GalleryViewModel>();
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            CloseSaveHeader(
                header: 'App-Galerie',
                onSave: () async {
                  final bool success = await viewModel.saveAll();
                  if (success) {
                    SnackBarService.showMessage(
                        'Alle Elemente erfolgreich gespeichert',
                        duration: const Duration(seconds: 2));
                  } else {
                    SnackBarService.showMessage(
                        'Fehler beim Speichern der Elemente!');
                  }
                },
                saveActive: viewModel.elements.isNotEmpty),
            if (viewModel.elements.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Noch keine Elemente vorhanden',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            ],
            // Gitter mit Bildern
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: viewModel.elements.length,
                  itemBuilder: (final context, final index) =>
                      _buildPhotoItem(context, viewModel, index),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: viewModel.elements.isEmpty
                    ? null
                    : () => _showDeleteAllDialog(context, viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Row(
                  // Stretch
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5.0,
                  children: [
                    Icon(Icons.delete_rounded,
                        color: viewModel.elements.isEmpty
                            ? Colors.grey
                            : Colors.white),
                    Text('Alle Bilder löschen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: viewModel.elements.isEmpty
                                ? Colors.grey
                                : Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Close Button (als 2. Möglichkeit zum Schließen der Galerie)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextCloseButton(stretch: true),
            ),
          ],
        ),
      ),
    );
  }
}
