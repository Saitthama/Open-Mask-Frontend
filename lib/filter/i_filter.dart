import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:open_mask/filter/face_geometry_calculator.dart';

import 'configs/filter_config.dart';

/// Interface für alle Filter.
/// Definiert gemeinsame Operationen für die Anwendung und Serialisierung von Filtern.
abstract class IFilter {
  /// Wendet den Filter auf das angegebene Gesicht an.
  void apply(
      final Face face, final Canvas canvas, final FaceGeometryCalculator fgc);

  /// Liefert die jeweilige Konfiguration der Filter‑Instanz zurück.
  FilterConfig? get config;

  /// Lädt alle externen Ressourcen für die Filter. <br>
  /// Der zurückgelieferte Boolean gibt an, ob das Laden erfolgreich war.
  Future<bool> load();

  /// Gibt die verwendete Ressourcen frei.
  void dispose();

  /// Methode zur JSON‑Serialisierung, welche den Filter in ein JSON-Objekt umwandelt.
  Map<String, dynamic> toJSON();

  /// Methode zur JSON-Serialisierung für den Export von Filtern.
  Map<String, dynamic> toExportAsJSON();

  /// Erstellt eine Fork eines Filters.
  IFilter fork();
}
