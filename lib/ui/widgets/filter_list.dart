import 'package:flutter/material.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';

import 'blue_text_button.dart';
import 'filter_list_tile.dart';

/// Zeigt eine Liste von Filtern (als [FilterListTile]) an.
class FilterList extends StatefulWidget {
  /// Konstruktor, über den die darzustellende [getFilterList] angegeben wird.
  const FilterList(
      {super.key,
      required this.getFilterList,
      this.onEdit,
      this.onDelete,
      this.onFork,
      this.changeNotifier,
      this.extraScrollHeight = 80,
      this.onSelected,
      this.isSelected});

  /// List der darzustellenden Filter.
  final List<IFilter> Function() getFilterList;

  /// Wird beim Drücken des Bearbeitungs-Buttons aufgerufen.
  final void Function(IFilter?)? onEdit;

  /// Wird beim Drücken des Delete-Buttons aufgerufen.
  final void Function(IFilter)? onDelete;

  /// Wird beim Drücken des Fork-Buttons aufgerufen.
  final void Function(IFilter)? onFork;

  /// Dient dazu, die Liste bei Änderungen zu aktualisieren.
  final ChangeNotifier? changeNotifier;

  /// Zusätzlicher Platz am Ende der Liste, um weiter scrollen zu können.
  final double? extraScrollHeight;

  /// Wird aufgerufen, wenn ein Filterelement ausgewählt wird.
  final Function(Filter filter)? onSelected;

  /// Gibt an, ob der Filter ausgewählt ist.
  final bool Function(Filter filter)? isSelected;

  @override
  State<FilterList> createState() => _FilterListState();
}

/// [State] der [FilterList].
class _FilterListState extends State<FilterList> {
  /// Wird aufgerufen, wenn der Change-Notifier eine Änderung meldet und lädt die Seite neu.
  /// <p> In [initState] wird die Variable so gesetzt, dass sie [setState] aufruft,
  /// Wird in [initState] als Listener zum Change-Notifier hinzugefügt und
  /// in [dispose] wieder entfernt.</p>
  late final VoidCallback _stateListener;

  @override
  void initState() {
    super.initState();

    _stateListener = () {
      if (context.mounted) {
        setState(() {});
      }
    };
    widget.changeNotifier?.addListener(_stateListener);
  }

  @override
  Widget build(final BuildContext context) {
    return widget.getFilterList().isEmpty
        ? _emptyFilterList(context)
        : _filterList(widget.getFilterList());
  }

  /// Eine Filterliste mit mind. einem Element.
  Widget _filterList(final List<IFilter> filterList) {
    return ListView.builder(
      itemCount: filterList.length + 1,
      itemBuilder: (final context, final index) {
        if (index >= filterList.length) {
          return SizedBox(height: widget.extraScrollHeight ?? 0);
        }
        Filter filter = filterList[index] as Filter;
        return FilterListTile(
          filter: filter,
          onEdit:
              widget.onEdit == null ? null : () => widget.onEdit?.call(filter),
          onDelete: widget.onDelete == null
              ? null
              : () => widget.onDelete?.call(filter),
          onFork:
              widget.onFork == null ? null : () => widget.onFork?.call(filter),
          onSelected: (final filter) {
            widget.onSelected?.call(filter);
            setState(() {});
          },
          isSelected: widget.isSelected?.call(filter) ?? false,
        );
      },
    );
  }

  /// Ein Platzhalter, falls kein Filter vorhanden ist.
  Widget _emptyFilterList(final BuildContext context) {
    final emptyText = const Text(
      'Noch keine Elemente vorhanden',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    );
    if (widget.onEdit == null) {
      return Center(
        child: emptyText,
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Hier finden Sie Ihre fertigen Filter',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          emptyText,
          const SizedBox(height: 24),
          BlueTextButton(
            'Filter erstellen',
            onPressed: () => widget.onEdit?.call(null),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.changeNotifier?.removeListener(_stateListener);

    super.dispose();
  }
}
