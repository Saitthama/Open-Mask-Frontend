import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/routing/app_shell.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/screens/filter_workshop_screen.dart';
import 'package:open_mask/ui/screens/login_screen.dart';
import 'package:open_mask/ui/screens/register_screen.dart';
import 'package:open_mask/ui/screens/settings_screen.dart';

/// Navigationsschlüssel für den nicht authentifizierten Bereich der App.
final notAuthNavigatorKey = GlobalKey<NavigatorState>();

/// [GoRoute]-Liste mit drei Branches/Tabs zur Navigation in der App für nicht authentifizierte Benutzer.
/// <ul>
///   <li>Login-Seite ([LoginScreen.routePath])</li>
///   <li>Registrierungs-Seite ([RegisterScreen.routePath])</li>
/// </ul>
final notAuthRoutes = [
  GoRoute(
      path: LoginScreen.routePath,
      builder: (final context, final state) => const LoginScreen()),
  GoRoute(
      path: RegisterScreen.routePath,
      builder: (final context, final state) => const RegisterScreen()),
];

/// Navigationsschlüssel für den Filterwerkstatt-Branch des authentifizierten Bereichs der App.
final shellFilterWorkshopNavigatorKey = GlobalKey<NavigatorState>();

/// Navigationsschlüssel für den Filteranwendungs-Branch des authentifizierten Bereichs der App.
final shellCameraNavigatorKey = GlobalKey<NavigatorState>();

/// Navigationsschlüssel für den Einstellungen-Branch des authentifizierten Bereichs der App.
final shellSettingsNavigatorKey = GlobalKey<NavigatorState>();

/// Eine [StatefulShellRoute] (in einer Liste als einziges Element) mit drei Branches/Tabs zur Navigation in der App für authentifizierte Benutzer.
/// <ul>
///   <li>Filterwerkstatt (Tab 0) <br>
///   Route: [FilterWorkshopScreen.routePath] <br>
///   Navigationsschlüssel: [shellFilterWorkshopNavigatorKey]
///   </li>
///   <li>Kamera/Filterverwendung (Tab 1) <br>
///   Route: [CameraScreen.routePath] <br>
///   Navigationsschlüssel: [shellCameraNavigatorKey]
///   </li>
///   <li>Einstellungen (Tab 2) <br>
///   Route: [SettingsScreen.routePath] <br>
///   Navigationsschlüssel: [shellSettingsNavigatorKey]
///   </li>
/// </ul>
/// Jeder Branch besitzt einen eigenen Navigator für unabhängige Stacks.
final authRoutes = [
  StatefulShellRoute.indexedStack(
      builder: (final context, final state, final navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        /// Filterwerkstatt-Branch
        StatefulShellBranch(
            navigatorKey: shellFilterWorkshopNavigatorKey,
            routes: [
              GoRoute(
                  path: FilterWorkshopScreen.routePath,
                  builder: (final context, final state) =>
                      const FilterWorkshopScreen(),
                  routes: [] // Erweiterbar um Sub-Pages mit Sub-Routen
                  ),
            ]),

        /// Kamera/Filterverwendung-Branch
        StatefulShellBranch(navigatorKey: shellCameraNavigatorKey, routes: [
          GoRoute(
              path: CameraScreen.routePath,
              builder: (final context, final state) => const CameraScreen(),
              routes: [] // Erweiterbar um Sub-Pages mit Sub-Routen
              ),
        ]),

        /// Einstellungen-Branch
        StatefulShellBranch(navigatorKey: shellSettingsNavigatorKey, routes: [
          GoRoute(
              path: SettingsScreen.routePath,
              builder: (final context, final state) => const SettingsScreen(),
              routes: [] // Erweiterbar um Sub-Pages mit Sub-Routen
              ),
        ])
      ])
];
