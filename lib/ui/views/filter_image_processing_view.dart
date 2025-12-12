import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_mask/ui/view_models/filter_image_processing_view_model.dart';
import 'package:provider/provider.dart';

/// View für die Anwendung von Filtern auf Bilder. Nutzt [FilterImageProcessingViewModel] für die Logik.
class FilterImageProcessingView extends StatefulWidget {
  /// Standard-Konstruktor.
  const FilterImageProcessingView({super.key});

  @override
  State<FilterImageProcessingView> createState() =>
      _FilterImageProcessingViewState();
}

/// [State] des [FilterImageProcessingView].
class _FilterImageProcessingViewState extends State<FilterImageProcessingView> {
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<FilterImageProcessingViewModel>();
    final imageWidget = (viewModel.imageFile == null)
        ? Container()
        : Image.file(viewModel.imageFile!);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 2.5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: Column(
          spacing: 10.0,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                IconButton(
                    padding: const EdgeInsets.all(0),
                    iconSize: 40,
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded)),
                // Titel
                Text(
                  'Filter-Bildverarbeitung',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                    padding: const EdgeInsets.all(4),
                    iconSize: 50,
                    onPressed:
                        (viewModel.imageFile != null && !viewModel.isProcessing)
                            ? viewModel.save
                            : null,
                    isSelected: viewModel.imageFile == null,
                    disabledColor: theme.iconTheme.color?.withAlpha(100),
                    icon: const Icon(Icons.save_rounded))
              ],
            ),
            (viewModel.imageFile == null)
                ? Expanded(child: Container())
                : Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: theme.dividerColor, width: 3)),
                        child: Stack(alignment: Alignment.center, children: [
                          FittedBox(child: imageWidget),
                          if (viewModel.isProcessing) ...[
                            const CircularProgressIndicator()
                          ]
                        ]),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () =>
                    viewModel.pickAndProcessImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5.0,
                  children: [
                    Icon(
                      Icons.camera,
                      color: Colors.white,
                    ),
                    Text(
                      'Foto aufnehmen',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () =>
                    viewModel.pickAndProcessImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5.0,
                  children: [
                    Icon(
                      Icons.image_search_rounded,
                      color: Colors.white,
                    ),
                    Text(
                      'Bild aus Galerie auswählen',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
