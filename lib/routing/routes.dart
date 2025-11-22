import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/screens/filter_workshop_screen.dart';
import 'package:open_mask/ui/screens/login_screen.dart';
import 'package:open_mask/ui/screens/register_screen.dart';
import 'package:open_mask/ui/screens/settings_screen.dart';

final router = GoRouter(initialLocation: LoginScreen.routePath, routes: [
  GoRoute(
      path: LoginScreen.routePath,
      builder: (final context, final state) => const LoginScreen()),
  GoRoute(
      path: RegisterScreen.routePath,
      builder: (final context, final state) => const RegisterScreen()),
  GoRoute(
    path: CameraScreen.routePath,
    //builder: (final context, final state) => const CameraScreen()),
    pageBuilder: (final context, final state) => CustomTransitionPage(
      child: const CameraScreen(),
      transitionsBuilder: (final context, final animation,
          final secondaryAnimation, final child) {
        final from = state.extra as String?;
        Offset beginOffset;
        switch (from) {
          case SettingsScreen.routePath:
            beginOffset = const Offset(-1, 0); // links nach rechts
            break;
          case FilterWorkshopScreen.routePath:
            beginOffset = const Offset(1, 0); // rechts nach links
            break;
          default:
            beginOffset = Offset.zero;
        }
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.ease);
        return SlideTransition(
          position: Tween(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    ),
  ),
  GoRoute(
    path: FilterWorkshopScreen.routePath,
    //builder: (final context, final state) => const FilterWorkshopScreen()),
    pageBuilder: (final context, final state) => CustomTransitionPage(
      child: const FilterWorkshopScreen(),
      transitionsBuilder: (final context, final animation,
          final secondaryAnimation, final child) {
        final from = state.extra as String?;
        Offset beginOffset;
        switch (from) {
          case SettingsScreen.routePath:
            beginOffset = const Offset(-1, 0); // links nach rechts
            break;
          case CameraScreen.routePath:
            beginOffset = const Offset(-1, 0); // links nach rechts
            break;
          default:
            beginOffset = Offset.zero;
        }
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.ease);
        return SlideTransition(
          position: Tween(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    ),
  ),
  GoRoute(
    path: SettingsScreen.routePath,
    //builder: (final context, final state) => const SettingsScreen())
    pageBuilder: (final context, final state) => CustomTransitionPage(
      child: const SettingsScreen(),
      transitionsBuilder: (final context, final animation,
          final secondaryAnimation, final child) {
        final from = state.extra as String?;
        Offset beginOffset;
        switch (from) {
          case FilterWorkshopScreen.routePath:
            beginOffset = const Offset(1, 0); // rechts nach links
            break;
          case CameraScreen.routePath:
            beginOffset = const Offset(1, 0); // rechts nach links
            break;
          default:
            beginOffset = Offset.zero;
        }
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.ease);
        return SlideTransition(
          position: Tween(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    ),
  ),
]);
