import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/screens/filter_workshop_screen.dart';
import 'package:open_mask/ui/screens/settings_screen.dart';

/// Navigationsleiste, mit der angemeldete Benutzer die Hauptseiten der App erreichen können.
class CustomNavigationBar extends StatelessWidget {
  /// Standard-Konstruktor.<br>
  /// [currentRoutePath] Gibt die Route der aktuellen Seite an, zu der nicht navigiert werden können soll.
  const CustomNavigationBar({super.key, required this.currentRoutePath});

  /// Gibt die Route der aktuellen Seite an, zu der nicht navigiert werden können soll.
  final String currentRoutePath;

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
        onPressed: () => currentRoutePath == FilterWorkshopScreen.routePath
            ? null
            : context.push(FilterWorkshopScreen.routePath,
                extra: currentRoutePath),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (currentRoutePath == FilterWorkshopScreen.routePath)
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
        isSelected: currentRoutePath == CameraScreen.routePath,
        onPressed: () => (currentRoutePath == CameraScreen.routePath)
            ? {}
            : context.push(CameraScreen.routePath, extra: currentRoutePath));
  }

  /// Liefert das Navigations-Widget für die Einstellungen zurück.
  Widget _settingsNavigator(final BuildContext context) {
    return SizedBox(
      height: 60,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        onPressed: () => currentRoutePath == SettingsScreen.routePath
            ? null
            : context.push(SettingsScreen.routePath, extra: currentRoutePath),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (currentRoutePath == SettingsScreen.routePath)
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
