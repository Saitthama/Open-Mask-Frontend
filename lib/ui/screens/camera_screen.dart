import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/camera_service.dart';
import 'package:open_mask/data/services/face_detection_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/hat_filter.dart';
import 'package:open_mask/filter/templates/mustache_filter.dart';
import 'package:open_mask/ui/views/filter_view.dart';
import 'package:open_mask/ui/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

import '../views/face_detector_view.dart';

class CameraScreen extends StatefulWidget {
  static const routePath = "/camera";

  final bool showMarkings;
  final bool showLandmarks;

  const CameraScreen(
      {this.showMarkings = true, this.showLandmarks = true, super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState(
      showMarkings: showMarkings, showLandmarks: showLandmarks);
}

class _CameraScreenState extends State<CameraScreen> {
  final bool _showMarkings;
  final bool _showLandmarks;
  late FaceDetectionService _faceDetectionService;
  late CameraService _cameraService;
  bool _faceDetectionInitialized = false;

  // TODO: Filter auswählen
  IFilter? _filter;

  _CameraScreenState({bool showMarkings = true, bool showLandmarks = true})
      : _showLandmarks = showLandmarks,
        _showMarkings = showMarkings;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    _faceDetectionService =
        Provider.of<FaceDetectionService>(context, listen: false);
    _cameraService = Provider.of<CameraService>(context, listen: false);
    await _cameraService.initialize();
    await _faceDetectionService.initialize();
    _faceDetectionInitialized = true;

    // TODO: ersetzen durch Filterauswahl, Filter sollen in der Filter Factory oder im Filter-Editor gebaut werden.
    FilterConfig mustacheConfig = FilterConfig(
        scale: MustacheFilter.defaultScale,
        offset: MustacheFilter.defaultOffset);
    FilterMeta meta = FilterMeta(
        name: 'Mustache Filter 1', description: 'Unterer Schnurrbart');
    FilterImage mustacheImage = FilterImage(
        filename: MustacheFilter.defaultImageFilename,
        assetPath: MustacheFilter.defaultAssetPath);
    MustacheFilter mustacheFilter = MustacheFilter(
        config: mustacheConfig, meta: meta, filterImage: mustacheImage);

    FilterMeta meta2 = FilterMeta(
        name: 'Mustache Filter 2', description: 'Oberer Schnurrbart');
    FilterConfig config2 = FilterConfig(
        offset: const Offset(0, 10),
        scale: const Scale(0.5, 0.5),
        opacity: 0.5);
    FilterImage onlineMustacheImage = FilterImage(
        filename: 'online_mustache',
        imageUrl: 'https://pngimg.com/uploads/moustache/moustache_PNG43.png');
    MustacheFilter mustacheFilter2 = MustacheFilter(
        config: config2, meta: meta2, filterImage: onlineMustacheImage);

    HatFilter hatFilter = FilterFactory.create(FilterType.hat) as HatFilter;
    hatFilter.meta.name = 'Hat Filter';
    hatFilter.meta.description = 'Hut-Filter';
    hatFilter.config.scale = const Scale(1.3, 1.2);

    FilterMeta metaComposite = FilterMeta(
        name: 'Hut-Schnurrbart-Filter', description: 'Schnurrbart und Hut');
    CompositeFilter compositeFilter = CompositeFilter(meta: metaComposite);
    final filterList = compositeFilter.filterList;
    filterList.add(mustacheFilter);
    filterList.add(mustacheFilter2);
    filterList.add(hatFilter);
    filterList
        .add(FilterFactory.create(FilterType.mask)..config?.opacity = 0.5);
    _filter = compositeFilter;

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePicture() async {
    try {
      final image = await _cameraService.takePicture();
      // TODO: Bildverarbeitung hier einfügen
    } catch (e) {
      SnackBarService.showMessage('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Nicht mehr notwendig, da Services über Provider verwaltet werden
  }

  @override
  Widget build(final BuildContext context) {
    if (!_faceDetectionInitialized ||
        !_cameraService.cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                CameraPreview(_cameraService.cameraController),
                FaceDetectorView(
                    showMarkings: _showMarkings, showLandmarks: _showLandmarks),
                FilterView(_filter!),
              ],
            ),
          ),
          // TODO: extrahieren & korrigieren, dass Positioned in einem Column ist (muss in einem Stack sein, oder darf nicht verwendet werden)
          // Schwarze Leiste mit Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.flash_on, color: Colors.white, size: 30),
                    onPressed: () {},
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: _takePicture,
                    child: const Icon(Icons.circle_outlined,
                        color: Colors.white, size: 30),
                  ),
                  IconButton(
                    icon: const Icon(Icons.handyman_outlined,
                        color: Colors.white, size: 30),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const CustomNavigationBar(currentRoute: CameraScreen.routePath),
        ],
      ),
    );

    /* Ohne UI
    // TODO: löschen, wenn UI funktioniert
    print("CameraPage build");
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          CameraPreview(_cameraService.cameraController),
          FaceDetectorView(showMarkings: _showMarkings, showLandmarks: _showLandmarks),
          FilterView(filter: _filter!),
        ],
      ),
    );*/
  }
}
