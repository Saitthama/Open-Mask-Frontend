import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_mask/ui/view_models/filter_image_processing_view_model.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';
import 'package:open_mask/ui/widgets/close_save_header.dart';
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 2.5),
        child: Column(
          spacing: 10.0,
          children: [
            CloseSaveHeader(
                header: 'Filter-Bildverarbeitung',
                onSave: viewModel.save,
                saveActive:
                    (viewModel.imageFile != null && !viewModel.isProcessing)),
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
              child: BlueTextButton(
                'Foto aufnehmen',
                onPressed: () =>
                    viewModel.pickAndProcessImage(ImageSource.camera),
                leadingIcon: Icons.camera,
                stretch: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: BlueTextButton(
                'Bild aus Galerie auswählen',
                onPressed: () =>
                    viewModel.pickAndProcessImage(ImageSource.gallery),
                leadingIcon: Icons.image_search_rounded,
                stretch: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
