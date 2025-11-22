import 'package:flutter/material.dart';
import 'package:open_mask/routing/routes.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/views/camera_view.dart';
import 'package:open_mask/ui/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

/// Seite, die die Kamera und Filterverwendung enthält. Die Kamera-UI ist in [CameraView] und die Logik in [CameraViewModel].
class CameraScreen extends StatefulWidget {
  /// Standard-Konstruktor.
  const CameraScreen({super.key});

  /// Route zu der Seite, über die diese erreicht werden kann.
  static const routePath = '/camera';

  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with RouteAware {
  late final CameraViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CameraViewModel(context);
    viewModel.pageVisible = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // RouteObserver registrieren
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    viewModel.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    // Seite wurde geöffnet
    viewModel.pageVisible = true;
    if (!viewModel.initializedAndLive) {
      viewModel.startCamera();
    }
  }

  @override
  void didPopNext() {
    // sichtbar
    viewModel.pageVisible = true;
    if (!viewModel.initializedAndLive) {
      viewModel.startCamera();
    }
  }

  @override
  void didPushNext() {
    // Andere Seite wurde drübergepushed --> unsichtbar
    viewModel.stopCamera();
    viewModel.pageVisible = false;
  }

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: const Scaffold(
        body: CameraView(),
        bottomNavigationBar:
            CustomNavigationBar(currentRoutePath: CameraScreen.routePath),
      ),
    );
  }
}
