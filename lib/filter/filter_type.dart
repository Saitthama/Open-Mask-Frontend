/// Enum, welches alle möglichen Filterarten/Filtertypen enthält.
enum FilterType {
  composite('Composite-Filter'),
  mustache('Schnurrbart'),
  hat('Hut'),
  mask('Maske'),
  leftEye('Linkes Auge'),
  rightEye('Rechtes Auge'),
  mouth('Mund'),
  leftColorEye('Linkes Farbauge'),
  rightColorEye('Rechtes Farbauge'),
  colorMask('Farbmaske'),
  lips('Lippen'),
  innerMouth('Mundinneres');

  /// Konstruktor.
  const FilterType(this.displayName);

  /// Anzeigename des Filtertyps.
  final String displayName;
}

/// Findet den passenden [FilterType] durch den String.
FilterType filterTypeFromString(final String value) {
  return FilterType.values.firstWhere(
      (final element) =>
          element.toString().split('.')[1].toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Unbekannter Filter-Typ $value'));
}
