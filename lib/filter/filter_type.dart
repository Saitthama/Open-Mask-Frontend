/// Enum, welches alle möglichen Filterarten/Filtertypen enthält
enum FilterType {
  composite,
  mustache,
  hat,
  mask,
  leftEye,
  rightEye,
  mouth,
  leftColorEye,
  rightColorEye,
  colorMask,
  lips,
  innerMouth,
}

/// Findet den passenden [FilterType] durch das String
FilterType filterTypeFromString(final String value) {
  return FilterType.values.firstWhere(
      (final element) =>
          element.toString().split('.')[1].toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Unbekannter Filter-Typ $value'));
}

/// Gibt Tab-Namen je nach Filterart an.
Map<FilterType, String> filterTypeNames = {
  FilterType.composite: 'Composite-Filter',
  FilterType.mustache: 'Schnurrbart',
  FilterType.hat: 'Hut',
  FilterType.mask: 'Maske',
  FilterType.leftEye: 'Linkes Auge',
  FilterType.rightEye: 'Rechtes Auge',
  FilterType.mouth: 'Mund',
  FilterType.leftColorEye: 'Linkes Farbauge',
  FilterType.rightColorEye: 'Rechtes Farbauge',
  FilterType.colorMask: 'Farbmaske',
  FilterType.lips: 'Lippen',
  FilterType.innerMouth: 'Mundinneres',
};
