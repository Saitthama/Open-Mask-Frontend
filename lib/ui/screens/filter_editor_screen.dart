import 'package:flutter/material.dart';
import 'package:open_mask/ui/view_models/filter_editor_view_model.dart';
import 'package:open_mask/ui/views/filter_editor_view.dart';
import 'package:provider/provider.dart';

/// Seite, die den Editor für die Erstellung und Bearbeitung von Filtern enthält.
/// Die Editor-UI wird vom [FilterEditorView] bereitgestellt und die Logik im [FilterEditorViewModel].
/// <ul>
///   <li>Enthält Routeninformationen über die Seite ([routePath]/[cameraBranchIndex]).</li>
///   <li>Verwaltet das zugehörige [FilterEditorViewModel] und [FilterEditorView].</li>
/// </ul>
class FilterEditorScreen extends StatefulWidget {
  /// Standard-Konstruktor
  const FilterEditorScreen({super.key});

  /// Route zur Seite, über die diese erreicht werden kann.
  static const routePath = '/filter-editor';

  @override
  State<FilterEditorScreen> createState() => _FilterEditorScreenState();
}

/// Hält den Status des [FilterEditorScreen].
class _FilterEditorScreenState extends State<FilterEditorScreen> {
  /// Das ViewModel, das die Editorlogik im aktuellen Zustand verwaltet.
  late final FilterEditorViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = FilterEditorViewModel(context);
    viewModel.initialize();
  }

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider.value(
        value: viewModel, child: const FilterEditorView());
  }
}
