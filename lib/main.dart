import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/routing/routes.dart';
import 'package:provider/provider.dart';

import 'data/services/automatic_login_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // Initialisiert Firebase

  final cameraService = CameraService();
  final faceDetectionService = FaceDetectionService(cameraService);
  AutomaticLoginService.autoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FaceDetectionService>.value(
            value: faceDetectionService),
        Provider<CameraService>.value(value: cameraService),
      ],
      child: const OpenMask(useFirebase: true),
    ),
  );
}

class OpenMask extends StatelessWidget {
  // um die Nutzung von Firebase für den Smoke-Test zu umgehen
  final bool useFirebase;

  const OpenMask({super.key, required this.useFirebase});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (!useFirebase) {
      return MaterialApp(title: "Test", home: PlaceholderHomeScreen());
    }

    return MaterialApp.router(
      title: 'Open-Mask',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            titleTextStyle: const TextStyle(color: Colors.black, fontSize: 23)),
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(color: Colors.red),
          hintStyle: TextStyle(color: Colors.grey),
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
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 23)),
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(color: Colors.red),
          hintStyle: TextStyle(color: Colors.grey),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smoke Test Placeholder')),
      body: Center(child: Text('App is running!')),
    );
  }
}
