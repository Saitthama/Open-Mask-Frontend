import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/model/scale.dart';

import 'configs/filter_config.dart';

abstract class IFilter {
  /// Wendet den Filter auf das Gesicht an.
  void apply(Face face, Canvas canvas, Size canvasSize, Scale scale,
      bool isFrontCamera);

  /// Jede Filter‑Instanz hält selbst eine Config.
  FilterConfig? get config;

  Map<String, dynamic> toJSON();
}
