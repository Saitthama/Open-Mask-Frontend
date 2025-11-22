import 'package:flutter/material.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/views/camera_view.dart';
import 'package:open_mask/ui/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

/// Seite, die die Kamera und Filterverwendung enthält. Die Kamera-UI ist in [CameraView] und die Logik in [CameraViewModel].
class CameraScreen extends StatelessWidget {
  /// Standard-Konstruktor.
  const CameraScreen({super.key});

  /// Route zu der Seite, über die diese erreicht werden kann.
  static const routePath = '/camera';

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider(
      create: (final _) => CameraViewModel(context),
      child: const Scaffold(
        body: CameraView(),
        bottomNavigationBar:
            CustomNavigationBar(currentRoutePath: CameraScreen.routePath),
      ),
    );
  }
}
