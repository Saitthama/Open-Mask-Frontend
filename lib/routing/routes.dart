import 'package:go_router/go_router.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/screens/filter_workshop_screen.dart';
import 'package:open_mask/ui/screens/login_screen.dart';
import 'package:open_mask/ui/screens/register_screen.dart';
import 'package:open_mask/ui/screens/settings_screen.dart';

final router = GoRouter(initialLocation: LoginScreen.routePath, routes: [
  GoRoute(
      path: LoginScreen.routePath, builder: (context, state) => LoginScreen()),
  GoRoute(
      path: RegisterScreen.routePath,
      builder: (context, state) => RegisterScreen()),
  GoRoute(
      path: CameraScreen.routePath,
      builder: (context, state) => CameraScreen()),
  GoRoute(
      path: FilterWorkshopScreen.routePath,
      builder: (context, state) => FilterWorkshopScreen()),
  GoRoute(
      path: SettingsScreen.routePath,
      builder: (context, state) => SettingsScreen())
]);
