import 'package:flutter/material.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/ui/screens/filter_editor_screen.dart';
import 'package:open_mask/ui/view_models/filter_editor_view_model.dart';
import 'package:open_mask/ui/views/face_markings_view.dart';
import 'package:open_mask/ui/views/filter_view.dart';
import 'package:open_mask/ui/widgets/add_filter_popup.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';
import 'package:open_mask/ui/widgets/delete_button.dart';
import 'package:open_mask/ui/widgets/face_markings_list_tile.dart';
import 'package:provider/provider.dart';

/// View, welches die UI für den Editor enthält und dem [FilterEditorScreen] bereitstellt.
/// Nutzt das [FilterEditorViewModel] für Logik.
class FilterEditorView extends StatelessWidget {
  /// Standard-Konstruktor.
  const FilterEditorView({super.key});

  @override
  Widget build(final BuildContext context) {
    final FilterEditorViewModel vm = context.watch<FilterEditorViewModel>();
    final theme = Theme.of(context);

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(vm.currentFilter == null
            ? ''
            : (vm.currentFilter as Filter).meta.name),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dummy-Gesicht
          Center(
            child: AspectRatio(
              aspectRatio: 1, // Alle Dummy-Bilder im 1:1 Format
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(vm.dummyAssetPath),
                  FaceMarkingsView(
                    faces: vm.dummyFaces,
                    processedSize: vm.processedDummySize,
                    isFrontCamera: false,
                    showFaceBox: vm.showFaceBox,
                    showLandmarks: vm.showLandmarks,
                    showContours: vm.showContours,
                    showMarkings: vm.showMarkings,
                  ),
                  if (vm.currentFilter != null)
                    FilterView(
                      vm.currentFilter!,
                      faces: vm.dummyFaces,
                      processedSize: vm.processedDummySize,
                      isFrontCamera: false,
                    )
                ],
              ),
            ),
          ),

          // Obere Buttons
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: BlueTextButton(
                    'Hinzufügen',
                    onPressed: () => _addFilter(context, vm),
                    stretch: true,
                  ),
                ),
                Expanded(child: Container()),
                Expanded(
                  flex: 3,
                  child: BlueTextButton(
                    'Importieren',
                    onPressed: null,
                    stretch: true,
                  ),
                ),
              ],
            ),
          ),

          // Untere Buttons
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Expanded(
                  flex: 3,
                  child: DeleteTextButton(
                    'Entfernen',
                    onPressed:
                        (vm.selectedEditedFilter == null) ? null : vm.delete,
                    stretch: true,
                  ),
                ),
                Expanded(
                  child: IconButton(
                      onPressed: () => _showOptions(context, vm),
                      icon: Icon(Icons.settings_rounded,
                          color: theme.iconTheme.color)),
                ),
                Expanded(
                  flex: 3,
                  child: BlueTextButton(
                    (vm.saved) ? 'Clear' : 'Speichern',
                    onPressed: vm.currentFilter == null ? null : vm.save,
                    stretch: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  /// Öffnet ein Popup, um einen Filter hinzuzufügen.
  void _addFilter(final BuildContext context, final FilterEditorViewModel vm) {
    showDialog(
        context: context,
        barrierColor: Theme.of(context).colorScheme.surface.withAlpha(180),
        builder: (final context) {
          return const AddFilterPopup();
        });
  }

  /// Zeigt erweiterte Optionen wie zum Wechseln des Dummys oder
  /// Ein- und Ausschalten verschiedener Gesichtsmarkierungen an.
  void _showOptions(
      final BuildContext context, final FilterEditorViewModel vm) {
    ThemeData theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (final _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.face,
                color: theme.iconTheme.color,
              ),
              title: const Text('Dummy wechseln'),
              onTap: () => vm.switchDummy(),
            ),
            FaceMarkingsListTile(viewModel: vm),
          ],
        );
      },
    );
  }
}
