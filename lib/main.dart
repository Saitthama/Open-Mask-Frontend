import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/routing/active_branch_notifier.dart';
import 'package:open_mask/routing/routes.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/screens/login_screen.dart';
import 'package:provider/provider.dart';

import 'data/services/automatic_login_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // Initialisiert Firebase

  // TODO: Andere Services zum Provider hinzufügen
  final faceDetectionService = FaceDetectionService();
  final cameraService = CameraService();
  final auth = AuthService.instance;
  AutomaticLoginService.autoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FaceDetectionService>.value(
            value: faceDetectionService),
        Provider<CameraService>.value(value: cameraService),
        ValueListenableProvider<int>.value(
            value: ActiveBranchNotifier.instance),
        ChangeNotifierProvider<AuthService>.value(value: auth)
      ],
      child: const OpenMask(useFirebase: true),
    ),
  );
}

class OpenMask extends StatelessWidget {
  const OpenMask({super.key, required this.useFirebase});

  // um die Nutzung von Firebase für den Smoke-Test zu umgehen
  final bool useFirebase;

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    if (!useFirebase) {
      return const MaterialApp(title: 'Test', home: PlaceholderHomeScreen());
    }
    return Consumer<AuthService>(
      builder: (final context, final auth, final _) {
        final router = GoRouter(
          navigatorKey: notAuthNavigatorKey,
          initialLocation:
              auth.loggedIn ? CameraScreen.routePath : LoginScreen.routePath,
          routes: auth.loggedIn ? authRoutes : notAuthRoutes,
        );

        return _materialApp(router);
      },
    );
  }

  MaterialApp _materialApp(final GoRouter router) {
    return MaterialApp.router(
      title: 'Open-Mask',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Colors.blueAccent,
            circularTrackColor: Colors.white.withAlpha(30)),
        useMaterial3: true,
        dividerColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        buttonTheme: const ButtonThemeData(
            colorScheme: ColorScheme.highContrastLight(primary: Colors.black)),
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 23)),
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: const TextStyle(color: Colors.red),
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[5],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.dark(),
        progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Colors.blueAccent,
            circularTrackColor: Colors.white.withAlpha(30)),
        scaffoldBackgroundColor: Colors.black,
        dividerColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 23)),
        buttonTheme: const ButtonThemeData(
            colorScheme: ColorScheme.highContrastDark(primary: Colors.white)),
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: const TextStyle(color: Colors.red),
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: router,
    );
  }
}

class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smoke Test Placeholder')),
      body: const Center(child: Text('App is running!')),
    );
  }
}
