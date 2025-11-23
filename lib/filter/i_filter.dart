import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/data/model/scale.dart';

import 'configs/filter_config.dart';

/// Inteface für alle Filter.
/// Definiert gemeinsame Operationen für die Anwendung und Serialisierung von Filtern.
abstract class IFilter {
  /// Wendet den Filter auf das angegebene Gesicht an.
  void apply(final Face face, final Canvas canvas, final Size canvasSize,
      final Scale scale, final bool isFrontCamera);

  /// Liefert die jeweilige Konfiguration der Filter‑Instanz zurück.
  FilterConfig? get config;

  /// Lädt alle externen Ressourcen für die Filter. <br>
  /// Der zurückgelieferte Boolean gibt an, ob das Laden erfolgreich war.
  Future<bool> load();

  /// Methode zur JSON‑Serialisierung, welche den Filter in ein JSON-Objekt umwandelt.
  Map<String, dynamic> toJSON();
}
