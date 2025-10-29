/// Enum, welches alle möglichen Filterarten/Filtertypen enthält
enum FilterType { composite, mustache, hat }

/// Findet den passenden [FilterType] durch das String
FilterType filterTypeFromString(final String value) {
  return FilterType.values.firstWhere(
      (final element) =>
          element.toString().split('.')[1].toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Unbekannter Filter-Typ $value'));
}
