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
      required super.uuid,
      required super.meta,
      required super.type,
      required FilterConfig super.config,
      required super.parentUuid,
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
    meta.iconAsWidget = Image.asset(defaultAssetPath);
  }

  /// Factory-Methode zur JSON‑Deserialisierung.
  factory ImageFilter.fromJSON(
      final Map<String, dynamic> json,
      final ImageFilter Function(
              {required FilterConfig config,
              required FilterImage? filterImage,
              required int? id,
              required String uuid,
              required String? parentUuid,
              required FilterMeta meta})
          filterCreator) {
    Map<String, dynamic> configJson = json['config'] ?? {};

    Map<String, dynamic> filterImageJson = json['filterImage'] ?? {};
    FilterImage filterImage = FilterImage.fromJSON(filterImageJson);

    FilterConfig filterConfig = FilterConfig.fromJSON(configJson);

    return filterCreator(
        id: json['id'] as int?,
        uuid: json['uuid'],
        meta: FilterMeta.fromJson(json['meta']),
        config: filterConfig,
        parentUuid: json['parentUUID'] as String?,
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
  ImageFilter fork({final bool createdByUser = true}) {
    ImageFilter fork = super.fork(createdByUser: createdByUser) as ImageFilter;
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
