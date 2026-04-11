import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';
import 'package:open_mask/ui/widgets/delete_button.dart';
import 'package:open_mask/ui/widgets/editable_text_tile.dart';
import 'package:open_mask/ui/widgets/form_header_text.dart';
import 'package:path/path.dart' as path;

/// Popup, welches zum Auswählen eines Bildes für den aktuell ausgewählten Bildfilter im Editor dient.
class ImageSelectionPopup extends StatefulWidget {
  /// Standard-Konstruktor.
  const ImageSelectionPopup(
      {super.key,
      required this.getImage,
      required this.setImage,
      this.onChanged});

  /// Getter, um das aktuelle [FilterImage] zu holen.
  final FilterImage Function() getImage;

  /// Setter, um das [FilterImage] zu setzen.
  final void Function(FilterImage? image) setImage;

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

  @override
  Widget build(final BuildContext context) {
    final overview = [
      if (widget.getImage().rawData != null)
        InteractiveViewer(
          maxScale: 10,
          minScale: 1,
          child: Image.memory(widget.getImage().rawData!),
        ),
      BlueTextButton('Bild aus Galerie auswählen',
          stretch: true,
          leadingIcon: Icons.image_search_rounded,
          onPressed: pickImage),
      BlueTextButton(
        'Bild aus Assets auswählen',
        stretch: true,
        leadingIcon: Icons.image_search_rounded,
        onPressed: openAssetSelection,
      ),
      BlueTextButton(
        'Bild über URL laden',
        stretch: true,
        leadingIcon: Icons.image_search_rounded,
        onPressed: openUrlSelection,
      ),
      DeleteTextButton(
        'Bild löschen',
        stretch: true,
        onPressed: () {
          widget.setImage(null);
          widget.onChanged?.call();
          if (mounted) context.pop();
        },
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
                onTap: () => loadFilterImageFromAsset(_assets[index]),
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

    final urlController =
        TextEditingController(text: widget.getImage().imageUrl);
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
        onPressed: () => loadFilterImageFromUrl(urlController.text),
      )
    ];

    final theme = Theme.of(context);
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
                          getText: () => widget.getImage().filename,
                          setText: (final newName) =>
                              widget.getImage().filename = newName),
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
  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    XFile? xFileImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFileImage == null) {
      return;
    }

    File imageFile = File(xFileImage.path);
    Uint8List rawData = await ImageService.loadImageFromFile(imageFile);
    ui.Image image = await ImageService.uint8ListToUiImage(rawData);
    FilterImage newFilterImage = FilterImage(
        image: image,
        rawData: rawData,
        filename: path.basenameWithoutExtension(imageFile.path),
        width: image.width,
        height: image.height);

    widget.setImage(newFilterImage);
    widget.onChanged?.call();
    if (mounted) context.pop();
  }

  /// Lädt das Filterbild von der angegebenen [url].
  Future<void> loadFilterImageFromUrl(final String url) async {
    final filename = url.split('/').last;
    final filterImage = FilterImage(
      filename: filename.split('.').first,
      imageUrl: url,
    );
    bool success = await filterImage.load();
    if (success) {
      widget.setImage(filterImage);
      widget.onChanged?.call();
      if (mounted) context.pop();
    } else {
      SnackBarService.showMessage('Fehler beim Laden des Bildes!');
    }
  }

  /// Lädt das Filterbild vom angegebenen [assetPath].
  Future<void> loadFilterImageFromAsset(final String assetPath) async {
    final filename = path.basenameWithoutExtension(assetPath);
    final filterImage = FilterImage(filename: filename, assetPath: assetPath);
    bool success = await filterImage.load();
    if (success) {
      widget.setImage(filterImage);
      widget.onChanged?.call();
      if (mounted) context.pop();
    } else {
      SnackBarService.showMessage('Fehler beim Laden des Bildes!');
    }
  }

  /// Öffnet die Asset-Auswahl.
  Future<void> openAssetSelection() async {
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
  Future<void> openUrlSelection() async {
    setState(() {
      _imageSelectionType = _ImageSelectionType.url;
    });
  }
}
