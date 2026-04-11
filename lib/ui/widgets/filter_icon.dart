import 'package:flutter/material.dart';
import 'package:open_mask/data/services/storage_service.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/templates/filter.dart';

import 'image_selection_popup.dart';

/// Stellt ein FilterIcon mit Hintergrund dar.
class FilterIcon extends StatefulWidget {
  /// Konstruktor, welcher den Filter bekommt, dessen Icon dargestellt werden soll.
  const FilterIcon({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.size,
    this.isEditable = false,
    this.onChanged,
  });

  /// Filter, dessen Icon dargestellt werden soll.
  final Filter filter;

  /// Gibt an, ob der Filter ausgewählt ist und das Icon daher markiert werden soll.
  final bool isSelected;

  /// Gibt die Größe an, in der das Icon dargestellt werden soll.
  final Size size;

  /// Gibt an, ob ein neues Icon durch anklicken ausgewählt können werden soll.
  final bool isEditable;

  /// Kann gesetzt werden, falls über Änderungen informiert werden soll.
  final VoidCallback? onChanged;

  @override
  State<FilterIcon> createState() => _FilterIconState();
}

/// [State] des [FilterIcon].
class _FilterIconState extends State<FilterIcon> {
  /// Gibt an, ob der Nutzer gerade dabei ist, auf die Icon-Auswahl zu drücken.
  bool isTappedDown = false;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final innerContainer = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (isDarkMode
                ? theme.colorScheme.onSurface
                : theme.colorScheme.surface)
            .withAlpha(220),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isSelected
              ? Colors.blue
              : isDarkMode
                  ? Colors.transparent
                  : theme.colorScheme.onSurface,
          width: 3,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: widget.isEditable && isTappedDown
            ? Center(
                child: Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    FittedBox(child: widget.filter.meta.iconAsWidget),
                    Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withAlpha(200))),
                    const FittedBox(
                      child: Icon(Icons.image_search_rounded,
                          color: Colors.indigo),
                    ),
                  ],
                ),
              )
            : FittedBox(
                child: widget.filter.meta.iconAsWidget,
              ),
      ),
    );
    return FittedBox(
      child: !widget.isEditable
          ? innerContainer
          : GestureDetector(
              onTap: () => openIconSelectionPopup(context),
              onTapDown: (final tapDownDetails) {
                setState(() {
                  isTappedDown = true;
                });
              },
              onTapCancel: () {
                setState(() {
                  isTappedDown = false;
                });
              },
              child: innerContainer,
            ),
    );
  }

  /// Öffnet das Popup für die Bildauswahl des Icons im angegebenen [context].
  void openIconSelectionPopup(final BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: theme.colorScheme.surface.withAlpha(180),
      builder: (final context) => ImageSelectionPopup(
        getImage: () => widget.filter.meta.icon ?? FilterImage(filename: ''),
        setImage: (final FilterImage? image) async {
          widget.filter.meta.icon = image;

          await widget.filter.meta.resizeIcon();
          StorageService.instance.saveFilter(widget.filter);
        },
        onChanged: () {
          setState(() {});
          widget.onChanged?.call();
        },
      ),
    ).then((final _) => setState(() {
          isTappedDown =
              false; // Zeigt Auswahl-Icon nicht mehr an, wenn die Filterauswahl geschlossen wird
        }));
  }
}
