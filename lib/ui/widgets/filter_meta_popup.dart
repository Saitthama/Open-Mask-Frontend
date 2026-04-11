import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/widgets/editable_text_tile.dart';
import 'package:open_mask/ui/widgets/filter_icon.dart';
import 'package:open_mask/ui/widgets/form_header_text.dart';
import 'package:open_mask/ui/widgets/text_with_checkbox.dart';

/// Popup zum Anzeigen und Bearbeiten von Filter-Metadaten.
class FilterMetaPopup extends StatefulWidget {
  /// Standard-Konstruktor.
  const FilterMetaPopup(this.filter, {super.key, this.onChanged});

  /// Der Filter, dessen Metadaten angezeigt werden sollen.
  final Filter filter;

  /// Kann gesetzt werden, falls über Änderungen informiert werden soll.
  final VoidCallback? onChanged;

  @override
  State<FilterMetaPopup> createState() => _FilterMetaPopupState();
}

/// [State] des [FilterMetaPopup].
class _FilterMetaPopupState extends State<FilterMetaPopup> {
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final bool isEditable =
        widget.filter.meta.createdBy?.id == AuthService.instance.user?.id;
    return Dialog(
      backgroundColor: theme.colorScheme.surface.withAlpha(220),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
            border: BoxBorder.all(
                color: theme.colorScheme.onSurface.withAlpha(220)),
            borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                children: [
                  FilterIcon(
                      filter: widget.filter,
                      isSelected: false,
                      size: const Size(40, 40)),
                  Expanded(
                      child: Text(
                    'Filter-Metadaten',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      iconSize: 40,
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close_rounded))
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormHeaderText('Name'),
                      EditableTextTile(
                          getText: () => widget.filter.meta.name,
                          setText: isEditable
                              ? (final newName) {
                                  widget.filter.meta.name = newName;
                                  widget.onChanged?.call();
                                  setState(() {});
                                }
                              : null),
                      const FormHeaderText('Beschreibung'),
                      EditableTextTile(
                          getText: () => widget.filter.meta.description,
                          setText: isEditable
                              ? (final newDescription) {
                                  widget.filter.meta.description =
                                      newDescription;
                                  widget.onChanged?.call();
                                  setState(() {});
                                }
                              : null),
                      const FormHeaderText('Ersteller'),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                        child: Text(widget.filter.meta.createdBy?.displayName ??
                            'Automatisch erstellt'),
                      ),
                      const FormHeaderText('Erstellungszeitpunkt'),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                        child: Text(
                            '${widget.filter.meta.createdAt ?? 'Automatisch erstellt'}'),
                      ),
                      const FormHeaderText('Änderungszeitpunkt'),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                        child: Text(
                            '${widget.filter.meta.updatedAt ?? 'Automatisch erstellt'}'),
                      ),
                      const FormHeaderText('Parent-UUID'),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                        child: Text(widget.filter.uuid),
                      ),
                      const FormHeaderText('Veröffentlichungsstatus'),
                      TextWithCheckbox(
                          checkedText: 'Öffentlich',
                          uncheckedText: 'Nicht öffentlich',
                          getValue: () => widget.filter.meta.isPublic,
                          setValue: isEditable
                              ? (final value) {
                                  widget.filter.meta.isPublic = value;
                                  widget.onChanged?.call();
                                  setState(() {});
                                }
                              : null),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
