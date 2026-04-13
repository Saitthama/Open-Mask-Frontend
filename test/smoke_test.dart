import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/main.dart';
import 'package:open_mask/routing/active_branch_notifier.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Smoke Test: App starts without crashing',
      (final WidgetTester tester) async {
    // 1. Erstelle Instanzen
    final authService = AuthService.instance;
    final faceService = FaceDetectionService();
    final cameraService = CameraService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: authService),
          ChangeNotifierProvider<FaceDetectionService>.value(
              value: faceService),
          Provider<CameraService>.value(value: cameraService),
          ValueListenableProvider<int>.value(
              value: ActiveBranchNotifier.instance),
        ],
        child: const OpenMask(),
      ),
    );

    // 2. Warte, bis der GoRouter und die Consumer fertig geladen haben
    await tester.pumpAndSettle();

    // 3. Überprüfung
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
