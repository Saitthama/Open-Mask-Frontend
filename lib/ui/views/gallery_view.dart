import 'package:flutter/material.dart';
import 'package:open_mask/ui/view_models/gallery_view_model.dart';
import 'package:provider/provider.dart';

/// View, welches Bilder in einer Galerie anzeigt.
class GalleryView extends StatelessWidget {
  /// Standard-Konstruktor.
  const GalleryView({super.key});

  /// Öffnet eine Nahansicht eines Photos.
  void _viewPhoto(final context, final viewModel, final index) {
    showDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.surface.withAlpha(138),
      builder: (final context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              maxScale: 10,
              minScale: 1,
              child: Image.file(viewModel.photos[index]),
            ),
          ),
        );
      },
    );
  }

  /// Baut ein Photo-Element für die Galerie.
  Widget _buildPhotoItem(final context, final viewModel, final index) {
    return GestureDetector(
      onTap: () => _viewPhoto(context, viewModel, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(viewModel.photos[index], fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final viewModel = context.watch<GalleryViewModel>();
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            // Titel
            AppBar(
              centerTitle: true,
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'App-Galerie',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                  itemCount: viewModel.photos.length,
                  itemBuilder: (final context, final index) =>
                      _buildPhotoItem(context, viewModel, index),
                ),
              ),
            ),
            // Close Button
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Schließen',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
