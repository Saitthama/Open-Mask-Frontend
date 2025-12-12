import 'package:open_mask/filter/i_filter.dart';

/// Datenhalter-Klasse, welche globale Filterdaten speichert.
class FilterStore {
  /// Privater Konstruktor für das Singleton-Pattern.
  FilterStore._internal();

  /// Singleton-Instanz.
  static final FilterStore instance = FilterStore._internal();

  /// Der aktuell ausgewählte Filter.
  IFilter? selectedFilter;
}
