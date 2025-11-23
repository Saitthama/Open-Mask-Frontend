import 'package:open_mask/filter/configs/filter_config.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/templates/filter.dart';

/// Abstrakte Basisklasse für Filter, die ein Bild verwenden (z. B. Bart, Hut, Maske).
abstract class ImageFilter extends Filter {
  /// Standard-Konstruktor.
  ImageFilter(
      {super.id,
      required super.meta,
      required super.type,
      required FilterConfig super.config,
      required this.filterImage})
      : _config = config;

  /// Bild mit Metadaten.
  FilterImage filterImage;

  /// Konfiguration aller ImageFilter, die vorhanden sein muss und nicht [null] sein darf.
  final FilterConfig _config;

  @override
  FilterConfig get config => _config;

  /// Lädt [filterImage] mit [FilterImage.load]. Der zurückgelieferte Boolean gibt an, ob das Laden erfolgreich war.
  @override
  Future<bool> load() async {
    return await filterImage.load();
  }

  @override
  Map<String, dynamic> toJSON() =>
      {...super.toJSON(), 'filterImage': filterImage.toJSON()};
}
