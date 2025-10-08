import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/model/scale.dart';

import 'configs/filter_config.dart';

/// Grundlage für alle Filter, welche die nötigen Funktionen von Filtern vorgibt.
abstract class IFilter {
  /// Wendet den Filter auf das Gesicht an.
  void apply(final Face face, final Canvas canvas, final Size canvasSize,
      final Scale scale, final bool isFrontCamera);

  /// Jede Filter‑Instanz hält selbst eine Config.
  FilterConfig? get config;

  /// Wandelt den Filter in JSON um.
  Map<String, dynamic> toJSON();
}
