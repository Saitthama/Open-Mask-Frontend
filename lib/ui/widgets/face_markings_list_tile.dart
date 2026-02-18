import 'package:flutter/material.dart';

/// Listenelement zum Ein- und Ausschalten verschiedener Tracking-Markierungen.
class FaceMarkingsListTile extends StatefulWidget {
  /// Standard-Konstruktor. <br>
  /// [viewModel] dient zum Aufruf von Funktionen zum Ein- und Ausschalten der Tracking-Markierung, sowie zum Abrufen ihres Zustands.
  const FaceMarkingsListTile({super.key, required this.viewModel});

  /// Dient zum Aufrufen von Funktionen zum Ein- und Ausschalten der Tracking-Markierung, sowie zum Abrufen ihres Zustands.
  final dynamic viewModel;

  @override
  State<FaceMarkingsListTile> createState() => _FaceMarkingsListTileState();
}

/// [State] des [FaceMarkingsListTile].
class _FaceMarkingsListTileState extends State<FaceMarkingsListTile> {
  /// Dient dazu, [setState] bei Änderungen des Zustands aufzurufen.
  late void Function() listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
    widget.viewModel.addListener(listener);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      selected: widget.viewModel.showMarkings,
      leading: widget.viewModel.showMarkings
          ? const Icon(Icons.face_retouching_natural)
          : const Icon(Icons.face_retouching_off),
      title: widget.viewModel.showMarkings
          ? const Text('Gesichtsmarkierungen ausschalten')
          : const Text('Gesichtsmarkierungen einschalten'),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            selected:
                widget.viewModel.showFaceBox && widget.viewModel.showMarkings,
            leading: widget.viewModel.showFaceBox
                ? const Icon(Icons.star)
                : const Icon(Icons.star_border),
            title: widget.viewModel.showFaceBox
                ? const Text('Gesichtsbox ausschalten')
                : const Text('Gesichtsbox einschalten'),
            onTap: widget.viewModel.switchShowFaceBox,
          ),
          ListTile(
            selected:
                widget.viewModel.showLandmarks && widget.viewModel.showMarkings,
            leading: widget.viewModel.showLandmarks
                ? const Icon(Icons.star)
                : const Icon(Icons.star_border),
            title: widget.viewModel.showLandmarks
                ? const Text('Landmarken ausschalten')
                : const Text('Landmarken einschalten'),
            onTap: widget.viewModel.switchShowLandmarks,
          ),
          ListTile(
              selected: widget.viewModel.showContours &&
                  widget.viewModel.showMarkings,
              leading: widget.viewModel.showContours
                  ? const Icon(Icons.star)
                  : const Icon(Icons.star_border),
              title: widget.viewModel.showContours
                  ? const Text('Konturen ausschalten')
                  : const Text('Konturen einschalten'),
              onTap: widget.viewModel.switchShowContours),
        ],
      ),
      onTap: widget.viewModel.switchShowMarkings,
    );
  }
}
