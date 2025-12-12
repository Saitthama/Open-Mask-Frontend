import 'package:flutter/material.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/screens/filter_workshop_screen.dart';
import 'package:open_mask/ui/screens/settings_screen.dart';

/// Navigationsleiste, mit der angemeldete Benutzer die Hauptseiten der App erreichen können.
class CustomNavigationBar extends StatelessWidget {
  /// Standard-Konstruktor.
  /// <ul>
  ///   <li>[currentIndex] gibt den Index der Route der aktuellen Seite an, zu der nicht navigiert werden können soll.</li>
  ///   <li>[onBranchSelected] wird bei der Auswahl eines Branches aufgerufen. <br>
  ///   Der [destinationIndex] gibt den Index der Seite an, zu der navigiert werden soll.
  ///   </li>
  /// </ul>
  const CustomNavigationBar(
      {super.key, required this.currentIndex, required this.onBranchSelected});

  /// Gibt den Index der Route der aktuellen Seite an, zu der nicht navigiert werden können soll.
  final int currentIndex;

  /// Wird bei der Auswahl eines Branches aufgerufen. <br>
  /// Der [destinationIndex] gibt den Index der Seite an, zu der navigiert werden soll.
  final void Function(int destinationIndex) onBranchSelected;

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SizedBox(
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(flex: 40, child: _filterWorkshopNavigator(context)),
              Expanded(flex: 23, child: _filterApplicationNavigator(context)),
              Expanded(flex: 40, child: _settingsNavigator(context))
            ],
          ),
        ),
      ),
    );
  }

  /// Liefert das Navigations-Widget für die Filterwerkstatt zurück.
  Widget _filterWorkshopNavigator(final BuildContext context) {
    return SizedBox(
      height: 60,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        onPressed: () =>
            onBranchSelected(FilterWorkshopScreen.filterWorkshopBranchIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              (currentIndex == FilterWorkshopScreen.filterWorkshopBranchIndex)
                  ? [
                      const Icon(Icons.create, color: Colors.indigo, size: 30),
                      const Text(
                        'Filterwerkstatt',
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ]
                  : [
                      const Icon(Icons.create_outlined, size: 30),
                      const Text('Filterwerkstatt'),
                    ],
        ),
      ),
    );
  }

  /// Liefert das Navigations-Widget für die Filteranwendung ([CameraScreen]) zurück.
  Widget _filterApplicationNavigator(final BuildContext context) {
    return IconButton(
        padding: const EdgeInsets.all(5),
        icon: ImageService.colourlessAppIcon,
        selectedIcon: CircleAvatar(
          foregroundImage:
              Image.asset('assets/images/icons/app-icon.jpeg').image,
          radius: 32,
        ),
        isSelected: currentIndex == CameraScreen.cameraBranchIndex,
        onPressed: () => onBranchSelected(CameraScreen.cameraBranchIndex));
  }

  /// Liefert das Navigations-Widget für die Einstellungen zurück.
  Widget _settingsNavigator(final BuildContext context) {
    return SizedBox(
      height: 60,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        onPressed: () => onBranchSelected(SettingsScreen.settingsBranchIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (currentIndex == SettingsScreen.settingsBranchIndex)
              ? [
                  const Icon(
                    Icons.settings,
                    size: 30,
                    color: Colors.indigo,
                  ),
                  const Text(
                    'Einstellungen',
                    style: TextStyle(color: Colors.indigo),
                  )
                ]
              : [
                  const Icon(Icons.settings_outlined, size: 30),
                  const Text('Einstellungen')
                ],
        ),
      ),
    );
  }
}
