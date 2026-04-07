import 'package:flutter/material.dart';
import 'package:open_mask/filter/filter_store.dart';
import 'package:open_mask/filter/templates/color_filter.dart'
    as om_color_filter;
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/filter/templates/image_filter.dart';
import 'package:open_mask/ui/screens/filter_editor_screen.dart';
import 'package:open_mask/ui/view_models/filter_editor_view_model.dart';
import 'package:open_mask/ui/views/face_markings_view.dart';
import 'package:open_mask/ui/views/filter_view.dart';
import 'package:open_mask/ui/widgets/add_filter_popup.dart';
import 'package:open_mask/ui/widgets/blue_text_button.dart';
import 'package:open_mask/ui/widgets/color_picker_popup.dart';
import 'package:open_mask/ui/widgets/delete_button.dart';
import 'package:open_mask/ui/widgets/editable_text_tile.dart';
import 'package:open_mask/ui/widgets/face_markings_list_tile.dart';
import 'package:open_mask/ui/widgets/filter_meta_popup.dart';
import 'package:open_mask/ui/widgets/filter_tile.dart';
import 'package:open_mask/ui/widgets/image_selection_popup.dart';
import 'package:open_mask/ui/widgets/round_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

/// View, welches die UI für den Editor enthält und dem [FilterEditorScreen] bereitstellt.
/// Nutzt das [FilterEditorViewModel] für Logik.
class FilterEditorView extends StatelessWidget {
  /// Standard-Konstruktor.
  const FilterEditorView({super.key});

  @override
  Widget build(final BuildContext context) {
    final FilterEditorViewModel vm = context.watch<FilterEditorViewModel>();
    final theme = Theme.of(context);

    final Size buttonSize = const Size(40, 40);

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: vm.currentFilter == null
            ? const Text('')
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.info_outline_rounded),
                      onPressed: () => _openFilterMetaPopup(
                          context, vm, vm.currentFilter as Filter)),
                  Flexible(
                      child: EditableTextTile(
                    getText: () => (vm.currentFilter as Filter).meta.name,
                    setText: !FilterStore.instance
                            .getPredefinedFilters()
                            .contains(vm.currentFilter)
                        ? (final text) => FilterStore.instance
                            .setCurrentlyEditedFilterName(text)
                        : null,
                  )),
                  const SizedBox(width: 30),
                ],
              ),
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

          // Linke Bearbeitungstools
          if (vm.isEditable && vm.selectedEditedFilter?.config != null)
            Positioned(
                left: 10,
                bottom: 90,
                top: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Opacity-Selection
                    if (vm.showOpacitySelection)
                      Expanded(
                        child: SfSliderTheme(
                          data: SfSliderThemeData(
                              tooltipBackgroundColor: Colors.blue,
                              overlayRadius: buttonSize.width / 2),
                          child: SfSlider.vertical(
                              activeColor: Colors.blue,
                              inactiveColor: Colors.blue,
                              min: 0.0,
                              max: 1.0,
                              enableTooltip: true,
                              tooltipPosition: SliderTooltipPosition.right,
                              tooltipTextFormatterCallback: (final dynamic
                                          actualValue,
                                      final String formattedText) =>
                                  '${((actualValue as double) * 10000).roundToDouble() / 100} %',
                              value: vm.selectedEditedFilter!.config!.opacity,
                              onChanged: (final newOpacity) =>
                                  vm.setOpacity(newOpacity)),
                        ),
                      ),
                    RoundIconButton(
                      icon: Icons.opacity_rounded,
                      onTap: vm.switchShowOpacitySelection,
                      size: buttonSize,
                    ),
                    const SizedBox(height: 10),

                    // Rotation-Selection
                    if (vm.showRotationSelection)
                      Expanded(
                        child: SfSliderTheme(
                          data: SfSliderThemeData(
                              tooltipBackgroundColor: Colors.blue,
                              overlayRadius: buttonSize.width / 2),
                          child: SfSlider.vertical(
                              activeColor: Colors.blue,
                              inactiveColor: Colors.blue,
                              min: 0.0,
                              max: 360.0,
                              enableTooltip: true,
                              stepSize: 1,
                              tooltipPosition: SliderTooltipPosition.right,
                              tooltipTextFormatterCallback:
                                  (final dynamic actualValue,
                                          final String formattedText) =>
                                      '${(actualValue as double).round()}°',
                              value: vm.selectedEditedFilter!.config!.rotation,
                              onChanged: (final newRotation) =>
                                  vm.setRotation(newRotation)),
                        ),
                      ),
                    RoundIconButton(
                      icon: Icons.rotate_right,
                      onTap: vm.switchShowRotationSelection,
                      size: buttonSize,
                    ),
                    const SizedBox(height: 10),

                    // Scale-Selection
                    if (vm.showScaleSelection)
                      Expanded(
                        child: SfSliderTheme(
                          data: SfSliderThemeData(
                              tooltipBackgroundColor: Colors.blue,
                              overlayRadius: buttonSize.width / 2),
                          child: SfSlider.vertical(
                              activeColor: Colors.blue,
                              inactiveColor: Colors.blue,
                              min: 0.0,
                              max: 3.0,
                              stepSize: 0.01,
                              enableTooltip: true,
                              tooltipPosition: SliderTooltipPosition.right,
                              tooltipTextFormatterCallback: (final dynamic
                                          actualValue,
                                      final String formattedText) =>
                                  '${((actualValue as double) * 100).round()}%',
                              value:
                                  vm.selectedEditedFilter!.config!.scale.scaleX,
                              onChanged: (final newScale) =>
                                  vm.setScale(newScale)),
                        ),
                      ),
                    RoundIconButton(
                      icon: Icons.photo_size_select_large_rounded,
                      onTap: vm.switchShowScaleSelection,
                      size: buttonSize,
                    )
                  ],
                )),

          // x-Offset-Bearbeitung
          if (vm.isEditable && vm.selectedEditedFilter?.config != null)
            Positioned(
                bottom: 55,
                left: 40,
                right: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SfSliderTheme(
                        data: SfSliderThemeData(
                            tooltipBackgroundColor: Colors.red,
                            overlayRadius: buttonSize.width / 2),
                        child: SfSlider(
                            activeColor: Colors.red,
                            inactiveColor: Colors.red,
                            min: -125,
                            max: 125,
                            stepSize: 1.0,
                            enableTooltip: true,
                            tooltipTextFormatterCallback:
                                (final dynamic actualValue,
                                        final String formattedText) =>
                                    'x=${(actualValue as double).round()}',
                            value: vm.selectedEditedFilter!.config!.offset.dx,
                            onChanged: (final newDx) => vm.setOffsetDx(newDx)),
                      ),
                    ),
                  ],
                )),

          // Rechte Bearbeitungstools
          Positioned(
              bottom: 90,
              top: 60,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Filter-Komponenten-Übersicht
                  if (vm.currentFilter is CompositeFilter)
                    Expanded(
                      child: SizedBox(
                        width: 50,
                        child: ReorderableListView.builder(
                            itemBuilder: (final context, final index) {
                              Filter filterItem =
                                  ((vm.currentFilter as CompositeFilter)
                                      .filterList[index] as Filter);
                              return FilterTile(
                                  key: Key('$index'),
                                  filter: filterItem,
                                  isSelected:
                                      vm.selectedEditedFilter == filterItem,
                                  size: const Size(30, 30),
                                  onTap: (final selected) {
                                    FilterStore.instance.selectedEditedFilter =
                                        selected;
                                  });
                            },
                            itemCount: (vm.currentFilter as CompositeFilter)
                                .filterList
                                .length,
                            onReorder: vm.reorder),
                      ),
                    ),

                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // y-Offset-Bearbeitung
                        Expanded(
                          child: (vm.isEditable &&
                                  vm.selectedEditedFilter?.config != null)
                              ? SfSliderTheme(
                                  data: SfSliderThemeData(
                                      tooltipBackgroundColor: Colors.green,
                                      overlayRadius: buttonSize.width / 2),
                                  child: SfSlider.vertical(
                                      activeColor: Colors.green,
                                      inactiveColor: Colors.green,
                                      min: -125,
                                      max: 125,
                                      stepSize: 1.0,
                                      enableTooltip: true,
                                      tooltipTextFormatterCallback: (final dynamic
                                                  actualValue,
                                              final String formattedText) =>
                                          'x=${(actualValue as double).round()}',
                                      value: vm.selectedEditedFilter!.config!
                                          .offset.dy,
                                      onChanged: (final newDy) =>
                                          vm.setOffsetDy(newDy)),
                                )
                              : Container(),
                        ),

                        // Bildauswahl
                        if (vm.isEditable &&
                            vm.selectedEditedFilter is ImageFilter)
                          RoundIconButton(
                            size: buttonSize,
                            onTap: () => _openSelectionPopup(context, vm),
                            icon: Icons.image_rounded,
                          ),

                        // Farbauswahl
                        if (vm.isEditable &&
                            vm.selectedEditedFilter
                                is om_color_filter.ColorFilter)
                          RoundIconButton(
                              size: buttonSize,
                              icon: Icons.color_lens_rounded,
                              onTap: () => _pickColor(context, vm)),
                      ],
                    ),
                  ),
                ],
              )),

          // Obere Buttons
          Positioned(
            top: 5,
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
            bottom: 5,
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
                        (vm.selectedEditedFilter == null) ? null : vm.remove,
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

  /// Öffnet das Popup für die Bildauswahl des aktuell ausgewählten Filters im angegebenen [context].
  void _openSelectionPopup(
      final BuildContext context, final FilterEditorViewModel vm) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: theme.colorScheme.surface.withAlpha(180),
      builder: (final context) => ImageSelectionPopup(
        onChanged: vm.onChanged,
      ),
    );
  }

  /// Öffnet das [FilterMetaPopup] zum Anzeigen und Verändern der Filter-Metadaten des aktuellen Filters im gegebenen [context].
  void _openFilterMetaPopup(final BuildContext context,
      final FilterEditorViewModel vm, final Filter filter) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: theme.colorScheme.surface.withAlpha(180),
      builder: (final context) =>
          FilterMetaPopup(filter, onChanged: vm.onChanged),
    );
  }

  /// Öffnet das [ColorPickerPopup], um eine Farbe für den Filter auszuwählen.
  void _pickColor(final BuildContext context, final FilterEditorViewModel vm) {
    final om_color_filter.ColorFilter filter =
        (vm.selectedEditedFilter as om_color_filter.ColorFilter);
    showDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.surface.withAlpha(180),
      builder: (final context) => ColorPickerPopup(
        getColor: () => filter.color,
        setColor: vm.setColor,
      ),
    );
  }
}
