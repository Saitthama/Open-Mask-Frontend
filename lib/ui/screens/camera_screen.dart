import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mask/routing/active_branch_notifier.dart';
import 'package:open_mask/routing/routes.dart';
import 'package:open_mask/ui/view_models/camera_view_model.dart';
import 'package:open_mask/ui/views/camera_view.dart';
import 'package:provider/provider.dart';

/// Seite, die die Kamera und Filterverwendung enthält. Die Kamera-UI ist im [CameraView] und die Logik im [CameraViewModel].
/// <ul>
///   <li>Enthält Routeninformationen über die Seite ([routePath]/[cameraBranchIndex]).</li>
///   <li>Verwaltet das zugehörige [CameraViewModel] und [CameraView].</li>
///   <li>Reagiert über den [ActiveBranchNotifier] auf Tab-Wechsel.</li>
///   <li>Startet/Stoppt die Kamera je nach Sichtbarkeit der Seite.</li>
/// </ul>
class CameraScreen extends StatefulWidget {
  /// Standard-Konstruktor.
  const CameraScreen({super.key});

  /// Route zu der Seite, über die diese erreicht werden kann.
  static const routePath = '/camera';

  /// Gibt den Index des Kamera-Tabs für das Shell-Routing an.
  static const int cameraBranchIndex = 1;

  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

/// Hält den Status des [CameraScreen].
class _CameraScreenState extends State<CameraScreen> {
  /// Das ViewModel, das die Kameralogik im aktuellen Zustand verwaltet.
  late final CameraViewModel viewModel;

  /// Index der letzten geöffneten Seite.
  int _lastBranchIndex = CameraScreen.cameraBranchIndex;

  @override
  void initState() {
    super.initState();
    viewModel = CameraViewModel(context);
    viewModel.pageVisible = true;

    ActiveBranchNotifier.instance.addListener(_onBranchChange);

    WidgetsBinding.instance
        .addPostFrameCallback((final _) => _onBranchOrSubPageChange());
  }

  /// Wird benutzt, um mit [context.push] innerhalb der Kameraseite zu navigieren. <br>
  /// Ruft [_onBranchOrSubPageChange] auf, um die Kameraaktivität zu aktualisieren.
  void _navigateTo(final String route) {
    context.push(route).then((final _) {
      //Subseite verlassen --> Kamera wieder einschalten
      _onBranchOrSubPageChange();
    });

    // Subseite öffnen --> Kamera stoppen
    _onBranchOrSubPageChange();
  }

  /// Wird aufgerufen, wenn im Branch (außer hier außerhalb des [PopScope]) ein Pop aufgerufen wird. <br>
  /// Ruft [_onBranchOrSubPageChange] auf, falls der Pop erfolgreich war.
  void _onPopInvokedWithResult(final successfullyPopped, final _) {
    if (successfullyPopped) {
      _onBranchOrSubPageChange();
    }
  }

  /// Wird aufgerufen, wenn sich der aktive Branch ändert. <br>
  /// Setzt den [_lastBranchIndex] und ruft [_onBranchOrSubPageChange] auf.
  void _onBranchChange() {
    // Wenn der aktuelle Branch gerade zurückgesetzt wird.
    if (ActiveBranchNotifier.instance.value == -1) {
      _lastBranchIndex = ActiveBranchNotifier.instance.value;
      return;
    }

    // Gibt die Route der letzten Seite an (z.B. /gallery nach Schließen dieser).
    // Ist /camera oder /gallery ... direkt nach dem Route-Wechsel.
    final route = shellCameraNavigatorKey.currentState?.widget.pages.last;

    bool branchReset = false;
    bool isCameraRoot = false;
    if (_lastBranchIndex == -1) {
      branchReset = true;
    } else if (route != null &&
        route.name == CameraScreen.routePath &&
        _lastBranchIndex != CameraScreen.cameraBranchIndex) {
      isCameraRoot = true;
    }

    _onBranchOrSubPageChange(
        branchReset: branchReset, isCameraRootAfterBranchChange: isCameraRoot);
    _lastBranchIndex = ActiveBranchNotifier.instance.value;
  }

  /// Wird aufgerufen, wenn sich der aktive Branch ändert oder wenn im aktuellen Branch navigiert wird. <br>
  /// Startet oder stoppt die Kamera abhängig davon, ob die Seite sichtbar ist. <br>
  /// Wenn [branchReset] auf true gesetzt wird, muss die Kamera aktiviert werden, wenn der Kamera-Branch ausgewählt wurde.
  void _onBranchOrSubPageChange(
      {final bool branchReset = false,
      final bool isCameraRootAfterBranchChange = false}) {
    //print('Branch or Sub-Page changed');
    final isActive =
        ActiveBranchNotifier.instance.value == CameraScreen.cameraBranchIndex;

    final navigator = shellCameraNavigatorKey.currentState;
    if (navigator == null) return;

    while (navigator.canPop() && branchReset) {
      context.pop();
    }

    // Prüfen, ob es die oberste Seite ist
    final canPop = navigator.canPop();

    // Letzte Branch-Route (ohne Sub-Route - z.B /camera)
    //final branchLocation = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    //print('branchLocation: $branchLocation');

    // Letzte Route (z.B. /camera/gallery)
    // --> beim Branch-Wechsel die des letzten Branches,
    // weil der Wechsel erst nach der Benachrichtigung durchgeführt wird
    final location = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .last
        .matchedLocation;
    final lastRouteIsCamera = location == CameraScreen.routePath;

    final isRoot =
        (lastRouteIsCamera || !canPop || isCameraRootAfterBranchChange);
    //print('location: $location');
    //print('lastRouteIsCamera: $lastRouteIsCamera');
    //print('canPop: $canPop');
    //print('isActive: $isActive');
    //print('isRoot: $isRoot');

    if (isActive && (isRoot || branchReset)) {
      if (!viewModel.initialized) {
        viewModel.initialize();
      } else {
        if (!viewModel.cameraLive && !viewModel.startingCamera) {
          viewModel.startCamera();
        }
      }
      viewModel.pageVisible = true;
    } else {
      if (viewModel.cameraLive) viewModel.stopCamera();
      viewModel.pageVisible = false;
    }
  }

  @override
  void dispose() {
    ActiveBranchNotifier.instance.removeListener(_onBranchOrSubPageChange);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: ChangeNotifierProvider.value(
          value: viewModel,
          child: CameraView(
            navigateTo: _navigateTo,
          )),
    );
  }
}
