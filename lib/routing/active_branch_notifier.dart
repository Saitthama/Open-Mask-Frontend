import 'package:flutter/material.dart';
import 'package:open_mask/ui/screens/camera_screen.dart';

/// Verwaltet den aktiven Tab-Index der App.
/// <ul>
///   <li>Ermöglicht es Widgets, auf Tab-Wechsel zu reagieren.</li>
///   <li>Wird als Singleton über [instance] bereitgestellt.</li>
///   <li>Wird auf den Index des aktuellen Branches gesetzt. </li>
///   <li>Wenn der Branch zurückgesetzt wird, wird der Wert zuerst auf -1 und dann auf den Branch-Index gesetzt.</li>
/// </ul>
class ActiveBranchNotifier extends ValueNotifier<int> {
  /// Privater Konstruktor für das Singleton-Pattern. Erstellt einen neuen Notifier mit dem Startwert des Kamera-Branches.
  ActiveBranchNotifier._internal() : super(CameraScreen.cameraBranchIndex);

  /// Singleton-Instanz des Notifiers. <br>
  static final ActiveBranchNotifier instance = ActiveBranchNotifier._internal();
}
