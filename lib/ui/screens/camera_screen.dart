import 'package:flutter/material.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/views/camera_view.dart';
import 'package:open_mask/ui/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  static const routePath = '/camera';

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider(
      create: (final _) => CameraViewModel(context),
      child: const Scaffold(
        body: CameraView(),
        bottomNavigationBar:
            CustomNavigationBar(currentRoute: CameraScreen.routePath),
      ),
    );
  }
}
