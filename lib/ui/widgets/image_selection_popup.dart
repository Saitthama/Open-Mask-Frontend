import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/templates/image_filter.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';
import 'package:open_mask/ui/widgets/editable_text_tile.dart';
import 'package:open_mask/ui/widgets/form_header_text.dart';

/// Popup, welches zum Auswählen eines Bildes für den aktuell ausgewählten Bildfilter im Editor dient.
class ImageSelectionPopup extends StatefulWidget {
  /// Standard-Konstruktor.
  const ImageSelectionPopup({super.key, this.onChanged});

  /// Kann gesetzt werden, falls über Änderungen informiert werden soll.
  final VoidCallback? onChanged;

  @override
  State<ImageSelectionPopup> createState() => _ImageSelectionPopupState();
}

enum _ImageSelectionType { overview, asset, url }

/// [State] des [ImageSelectionPopup].
class _ImageSelectionPopupState extends State<ImageSelectionPopup> {
  /// Gibt an, welche Auswahl aktuell geöffnet sein soll.
  _ImageSelectionType _imageSelectionType = _ImageSelectionType.overview;

  /// Enthält alle verfügbaren Assets, falls diese geladen wurden.
  List<String> _assets = [];

  /// Wird aufgerufen, wenn die [FilterStore]-Instanz aktualisiert wird und lädt die Seite neu.
  /// <p> In [initState] wird die Variable so gesetzt, dass sie [setState] aufruft,
  /// Wird in [initState] als Listener zur [FilterStore]-Instanz hinzugefügt und
  /// in [dispose] wieder entfernt.</p>
  late final VoidCallback _stateListener;

  @override
  void initState() {
    super.initState();
    _stateListener = () => setState(() {});
    FilterStore.instance.addListener(_stateListener);
  }

  @override
  Widget build(final BuildContext context) {
    final overview = [
      BlueTextButton('Bild aus Galerie auswählen',
          stretch: true,
          leadingIcon: Icons.image_search_rounded,
          onPressed: _pickImage),
      BlueTextButton(
        'Bild aus Assets auswählen',
        stretch: true,
        leadingIcon: Icons.image_search_rounded,
        onPressed: _openAssetSelection,
      ),
      BlueTextButton(
        'Bild über URL laden',
        stretch: true,
        leadingIcon: Icons.image_search_rounded,
        onPressed: _openUrlSelection,
      ),
    ];

    final assetSelection = [
      const FormHeaderText('Asset-Auswahl'),
      Padding(
        padding: const EdgeInsets.all(12),
        child: LimitedBox(
          maxHeight: MediaQuery.of(context).size.height * 0.35,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _assets.length,
            itemBuilder: (final context, final index) {
              return GestureDetector(
                onTap: () async {
                  bool success = await FilterStore.instance
                      .loadSelectedEditedFilterImageFromAsset(_assets[index]);
                  if (!success) {
                    SnackBarService.showMessage(
                        'Fehler beim Laden des Bildes!');
                  } else if (context.mounted) {
                    widget.onChanged?.call();
                    context.pop();
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(_assets[index], fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
      ),
    ];

    final urlController = TextEditingController(
        text: (FilterStore.instance.selectedEditedFilter is ImageFilter)
            ? (FilterStore.instance.selectedEditedFilter as ImageFilter)
                .filterImage
                .imageUrl
            : null);
    final urlSelection = [
      const FormHeaderText('Url'),
      TextFormField(
          controller: urlController,
          decoration: const InputDecoration(
              hintText: 'https://www.example.com/image.png'),
          validator: (final value) {
            return (value == null ||
                    value.isEmpty ||
                    Uri.tryParse(value) == null)
                ? 'Bitte gültige Url eingeben'
                : null;
          }),
      BlueTextButton(
        'Bild laden',
        onPressed: () async {
          bool success = await FilterStore.instance
              .loadSelectedEditedFilterImageFromUrl(urlController.text);
          if (!success) {
            SnackBarService.showMessage('Fehler beim Laden des Bildes!');
          } else if (context.mounted) {
            widget.onChanged?.call();
            context.pop();
          }
        },
      )
    ];

    final theme = Theme.of(context);
    ImageFilter imageFilter =
        (FilterStore.instance.selectedEditedFilter as ImageFilter);
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
              Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: DefaultTextStyle(
                      style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ) ??
                          const TextStyle(),
                      child: EditableTextTile(
                          getText: () => imageFilter.filterImage.filename,
                          setText: (final newName) =>
                              imageFilter.filterImage.filename = newName),
                    ),
                  ),
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      iconSize: 40,
                      onPressed: () {
                        if (_imageSelectionType ==
                            _ImageSelectionType.overview) {
                          context.pop();
                        } else {
                          setState(() {
                            _imageSelectionType = _ImageSelectionType.overview;
                          });
                        }
                      },
                      icon: const Icon(Icons.close_rounded))
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  if (_imageSelectionType == _ImageSelectionType.overview)
                    ...overview,
                  if (_imageSelectionType == _ImageSelectionType.asset)
                    ...assetSelection,
                  if (_imageSelectionType == _ImageSelectionType.url)
                    ...urlSelection,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Öffnet die Galerieauswahl.
  Future<void> _pickImage() async {
    bool success = await FilterStore.instance.pickSelectedEditedFilterImage();
    if (success) {
      widget.onChanged?.call();
      if (mounted) context.pop();
    }
  }

  /// Öffnet die Asset-Auswahl.
  Future<void> _openAssetSelection() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest
        .listAssets()
        .where((final String key) => key.startsWith('assets/images/filter'))
        .toList();
    setState(() {
      _assets = assets;
      _imageSelectionType = _ImageSelectionType.asset;
    });
  }

  /// Öffnet die URL-Auswahl.
  Future<void> _openUrlSelection() async {
    setState(() {
      _imageSelectionType = _ImageSelectionType.url;
    });
  }

  @override
  void dispose() {
    FilterStore.instance.removeListener(_stateListener);
    super.dispose();
  }
}
