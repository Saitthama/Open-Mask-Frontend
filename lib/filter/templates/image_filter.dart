import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/geometry_service.dart';
import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_meta.dart';
import 'package:open_mask/filter/templates/filter.dart';

/// Abstrakte Basisklasse für Filter, die ein Bild verwenden (z.B. Bart, Hut, Maske).
abstract class ImageFilter extends Filter {
  /// Standard-Konstruktor.
  ImageFilter(
      {required super.id,
      required super.meta,
      required super.type,
      required FilterConfig super.config,
      required super.parentId,
      required final FilterImage? filterImage,
      required this.defaultImageFilename,
      required this.defaultAssetPath,
      this.defaultScale,
      this.defaultOffset})
      : _config = config {
    if (filterImage != null) {
      this.filterImage = filterImage;
    }
    if (config.offset == FilterConfig.defaultOffset && defaultOffset != null) {
      config.offset = defaultOffset!;
    }
    if (config.scale == FilterConfig.defaultScale && defaultScale != null) {
      config.scale = defaultScale!;
    }
    if (meta.iconIsDefault) {
      meta.icon = Image.asset(defaultAssetPath);
    }
  }

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory ImageFilter.fromJSON(
      final Map<String, dynamic> json,
      final ImageFilter Function(
              {required FilterConfig config,
              required FilterImage? filterImage,
              int? id,
              int? parentId,
              required FilterMeta meta})
          filterCreator) {
    Map<String, dynamic> configJson = json['config'] ?? {};

    Map<String, dynamic> filterImageJson = json['filterImage'] ?? {};
    FilterImage filterImage = FilterImage.fromJSON(filterImageJson);

    FilterConfig filterConfig = FilterConfig.fromJSON(configJson);

    return filterCreator(
        id: json['id'] as int,
        meta: FilterMeta.fromJson(json['meta']),
        config: filterConfig,
        parentId: json['parentId'] as int,
        filterImage: filterImage);
  }

  /// Bild mit Metadaten.
  late FilterImage filterImage =
      FilterImage(filename: defaultImageFilename, assetPath: defaultAssetPath);

  /// Konfiguration aller ImageFilter, die vorhanden sein muss und nicht [null] sein darf.
  final FilterConfig _config;

  /// Standardmäßiger Dateiname des Filter-Bildes ([FilterImage.filename]).
  final String defaultImageFilename;

  /// Standarmäßiger Asset-Path ([FilterImage.assetPath]).
  final String defaultAssetPath;

  /// Standardmäßiger Scale.
  final Scale? defaultScale;

  /// Standardmäßige relative Position des Filters ([ImageFilterConfig.offset]).
  final Offset? defaultOffset;

  /// Gibt die Position der Landmarke an, auf dessen Basis der Filter gerendert werden soll.
  @protected
  Offset? position;

  /// Gibt optional die Basisgröße des Filters (ohne Skalierung aus der [config]) an,
  /// falls diese nicht anhand der Gesichtsgröße berechnet werden soll.
  @protected
  Size? filterSize;

  @override
  FilterConfig get config => _config;

  /// Lädt [filterImage] mit [FilterImage.load]. Der zurückgelieferte Boolean gibt an, ob das Laden erfolgreich war.
  @override
  Future<bool> load() async {
    return await filterImage.load();
  }

  @override
  void dispose() {
    filterImage.dispose();
  }

  @override
  Map<String, dynamic> toJSON() =>
      {...super.toJSON(), 'filterImage': filterImage.toJSON()};

  @override
  ImageFilter fork() {
    ImageFilter fork = super.fork() as ImageFilter;
    fork.filterImage = filterImage.fork();
    fork.position = position;
    fork.filterSize = filterSize;
    return fork;
  }

  @override
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc) {
    if (filterImage.image == null) {
      return;
    }
    position ??= fgc.calculateDynamicFaceCenter(face);
    // Rotation berechnen
    final totalRotation =
        fgc.calculateFaceZRotation(face, extraRotation: config.rotation);

    // Gesichtsgröße und Offset berechnen
    final Size faceSize = fgc.calculateDynamicFaceSize(face);

    final Offset relativeOffset = GeometryService.scaleOffset(
        config.offset, faceSize.width, faceSize.height);
    final rotatedOffset =
        GeometryService.rotateOffset(relativeOffset, totalRotation);

    final filterWidth =
        (filterSize?.width ?? faceSize.width) * config.scale.scaleX;
    final filterHeight =
        (filterSize?.height ?? faceSize.height) * config.scale.scaleY;

    final imageRect = Rect.fromCenter(
      center: Offset(
          position!.dx + rotatedOffset.dx, position!.dy + rotatedOffset.dy),
      width: filterWidth,
      height: filterHeight,
    );

    canvas.save();

    // Gesichtsrotation (Neigung) + ExtraRotation berechnen
    canvas.translate(imageRect.center.dx, imageRect.center.dy);
    canvas.rotate(totalRotation);
    canvas.translate(-imageRect.center.dx, -imageRect.center.dy);

    paintImage(
        canvas: canvas,
        rect: imageRect,
        image: filterImage.image!,
        fit: (filterImage.image!.height.toDouble() / filterHeight >
                filterImage.image!.width.toDouble() / filterWidth)
            ? BoxFit.fitHeight
            : BoxFit.fitWidth,
        opacity: config.opacity,
        filterQuality: FilterQuality.high);

    canvas.restore();
  }
}
