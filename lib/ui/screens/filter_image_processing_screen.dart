import 'package:flutter/cupertino.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';
import 'package:open_mask/ui/view_models/filter_image_processing_view_model.dart';
import 'package:open_mask/ui/views/filter_image_processing_view.dart';
import 'package:provider/provider.dart';

/// Seite, die die Filter-Bildverarbeitung enthält. Die UI ist im [FilterImageProcessingView] und die Logik im [FilterImageProcessingViewModel].
/// <ul>
///   <li>Enthält Routeninformationen über die Seite ([routePath]).</li>
///   <li>Verwaltet das zugehörige [FilterImageProcessingViewModel] und [FilterImageProcessingView].</li>
/// </ul>
class FilterImageProcessingScreen extends StatelessWidget {
  /// Standard-Konstruktor.
  const FilterImageProcessingScreen({super.key});

  /// Route zu der Seite, über die diese als Subseite des [CameraScreen] erreicht werden kann.
  static const routePath = '/image-processing';

  @override
  Widget build(final BuildContext context) {
    return ChangeNotifierProvider(
        create: (final _) =>
            FilterImageProcessingViewModel()..initialize(context),
        child: const FilterImageProcessingView());
  }
}
