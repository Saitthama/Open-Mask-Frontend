import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:open_mask/data/model/image_mime_type.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/filter/templates/image_filter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'image_service.dart';

/// Service zur Verwaltung des Zugriffs auf den Speicher.
class StorageService {
  /// Privater Konstruktor für das Singleton-Pattern.
  StorageService._internal();

  /// Singleton-Instanz.
  static final StorageService instance = StorageService._internal();

  /// Pfad zum internen App-Speicher für Benutzerdateien.
  Directory? _docsDir;

  /// Ordner für alle Dateien des aktuellen Nutzers.
  Directory get userDir => Directory(
      '${_docsDir!.path}/users/${AuthService.instance.user?.id ?? ''}');

  /// Ordner für die Photos des aktuellen Nutzers.
  Directory get userPhotosDir => Directory('${userDir.path}/photos');

  /// Ordner für die Filtersammlung des aktuellen Nutzers.
  Directory get userFiltersDir => Directory('${userDir.path}/filters');

  /// Ordner für die Speicherung eines Filters.
  /// <p>
  /// <b>users/{user-id}/filters/</b>
  /// <ul>
  /// <li>
  /// <b>{filter-uuid}/</b>
  /// <ul>
  ///   <li>filter.json</li>
  ///   <li>image.png</li>
  /// </ul>
  /// </li>
  /// <li>
  /// <b>{filter-uuid}/</b>
  /// <ul>
  ///   <li>filter.json</li>
  /// </ul>
  /// </li>
  /// <li>
  /// <b>{composite-uuid}/</b>
  /// <ul>
  ///   <li>filter.json</li>
  ///   <li>
  ///     <b>children/</b>
  ///     <ul>
  ///       <li>
  ///         <b>{child-uuid}/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///           <li>image.png</li>
  ///         </ul>
  ///       </li>
  ///       <li>
  ///         <b>{child-uuid}/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///         </ul>
  ///       </li>
  ///       <li>...</li>
  ///     </ul>
  ///   </li>
  /// </ul>
  /// </li>
  /// <li>...</li>
  /// </ul>
  /// </p>
  Directory filterDir(final Filter filter) =>
      Directory('${userFiltersDir.path}/${filter.uuid}');

  /// Ordner für die Speicherung eines Teilfilters im [parent]-Ordner.
  ///
  /// <p>
  /// <b>users/{user-id}/filters/{composite-uuid}/</b>
  /// <ul>
  ///   <li>filter.json</li>
  ///   <li>
  ///     <b>children/</b>
  ///     <ul>
  ///       <li>
  ///         <b>{child-uuid}/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///           <li>image.png</li>
  ///         </ul>
  ///       </li>
  ///       <li>
  ///         <b>{child-uuid}/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///         </ul>
  ///       </li>
  ///       <li>
  ///         <b>{composite-child-uuid}/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///           <li>
  ///             <b>children/</b>
  ///             <ul>
  ///               <li>
  ///                 <b>{child-uuid}/</b>
  ///                 <ul>
  ///                   <li>filter.json</li>
  ///                 </ul>
  ///               </li>
  ///               <li>
  ///                 <b>{child-uuid}/</b>
  ///                 <ul>
  ///                   <li>filter.json</li>
  ///                   <li>image.png</li>
  ///                 </ul>
  ///               </li>
  ///               <li>...</li>
  ///             </ul>
  ///           </li>
  ///         </ul>
  ///       </li>
  ///       <li>...</li>
  ///     </ul>
  ///   </li>
  /// </ul>
  /// </p>
  Directory filterChildDir(final Directory parent, final Filter child) =>
      Directory('${parent.path}/children/${child.uuid}');

  /// Geht sicher, dass der Ordner existiert.
  Future<Directory> ensureDirExists(final Directory dir) async {
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Speichert ein aufgenommenes Foto ([picture]) in die App-Galerie unter dem Namen [filename].
  Future<File> savePhotoToAppGallery(
      final XFile picture, final String filename) async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    final dir = await ensureDirExists(userPhotosDir);
    final file = File('${dir.path}/$filename');
    return File(picture.path).copy(file.path);
  }

  /// Speichert das übergebene [image] in die App-Galerie mit dem angegebenen [filename].
  Future<File> saveUiImageToAppGallery(
      final ui.Image image, final String filename) async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    final dir = await ensureDirExists(userPhotosDir);
    final File file = File('${dir.path}/$filename');
    return ImageService.saveUiImageToFile(image, file);
  }

  /// Listet die Fotodateien aus der App-Galerie auf.
  Future<List<File>> loadLocalPhotos() async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    final dir = await ensureDirExists(userPhotosDir);
    final files = Directory(dir.path)
        .listSync()
        .whereType<File>()
        .where((final file) => ImageMimeType.values
            .map((final ImageMimeType mimeType) => mimeType.extension)
            .contains(file.path.split('.').last))
        .toList()
      ..sort((final a, final b) => b.path.compareTo(a.path)); // neueste zuerst

    return files;
  }

  /// Speichert einen Filter im internen App-Speicher.
  Future<Directory> saveFilter(final Filter filter) async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    Directory dir = filterDir(filter);
    // alte Version löschen und neuen leeren Ordner erstellen
    if (await dir.exists()) await dir.delete(recursive: true);
    await ensureDirExists(filterDir(filter));

    final filterAsJSON = filter.toExportAsJSON();
    await _saveFilterRecursively(dir, filter, filterAsJSON);

    final entities = dir.listSync(recursive: true);
    return dir;
  }

  /// Speichert rekursiv einen Filter im angegebenen [filterDir].
  Future<void> _saveFilterRecursively(final Directory filterDir,
      final Filter filter, final Map<String, dynamic> filterAsJSON) async {
    if (filter is CompositeFilter) {
      List<IFilter> filterList = filter.filterList;
      List<Map<String, dynamic>> filterListAsJSON = filterAsJSON['filterList'];
      for (int i = 0; i < filterList.length; i++) {
        final Filter child = filterList[i] as Filter;
        final Map<String, dynamic> childAsJSON = filterListAsJSON[i];
        final Directory childDir =
            await ensureDirExists(filterChildDir(filterDir, child));
        await _saveFilterRecursively(childDir, child, childAsJSON);
      }
      filterAsJSON.remove('filterList');
    }

    File file = File('${filterDir.path}/filter.json');
    await file.writeAsString(jsonEncode(filterAsJSON));

    if (filter is ImageFilter) {
      if (filter.filterImage.rawData == null) {
        final success = await filter.filterImage.load();
        if (!success) return;
      }
      File imageFile = File(
          '${filterDir.path}/${filter.filterImage.filename}.${filter.filterImage.mimeType?.extension}');
      await imageFile.writeAsBytes(filter.filterImage.rawData!, flush: true);
      if (filter.filterImage.image == null) {
        filter.filterImage.dispose(); // wird nicht gerade verwendet
      }
    }
  }

  /// Lädt alle Filter im Ordner des Nutzers.
  Future<List<IFilter>> loadAllFilters() async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    Directory dir = await ensureDirExists(userFiltersDir);
    final entities = dir.listSync(recursive: true);
    List<IFilter> filters = [];
    final filterDirs = dir.listSync().whereType<Directory>();
    for (final Directory filterDir in filterDirs) {
      IFilter? filter = await loadFilter(filterDir);
      if (filter != null) {
        filters.add(filter);
      }
    }
    return filters;
  }

  /// Lädt den Filter aus dem angegebenen Ordner.
  Future<IFilter?> loadFilter(final Directory filterDir) async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    if (!await filterDir.exists()) {
      return null;
    }

    Map<String, dynamic>? filterAsJSON =
        await _loadFilterAsJSONRecursively(filterDir);
    if (filterAsJSON == null) {
      return null;
    }

    IFilter filter = FilterFactory.fromJSON(filterAsJSON);
    await _loadFilterResourcesRecursively(filterDir, filter);
    return filter;
  }

  /// Lädt die Ressourcen des Filters rekursiv aus dem angegebenen Ordner.
  Future<void> _loadFilterResourcesRecursively(
      final Directory filterDir, final IFilter filter) async {
    final childrenDir = Directory('${filterDir.path}/children');
    if (await childrenDir.exists() && filter is CompositeFilter) {
      final childDirs = childrenDir.listSync().whereType<Directory>();
      final children = (filter).filterList;

      for (final Directory childDir in childDirs) {
        final child = children
            .where((final element) =>
                (element as Filter).uuid == basename(childDir.path))
            .firstOrNull;
        if (child == null) continue;
        await _loadFilterResourcesRecursively(childDir, child);
      }
    }

    if (filter is! ImageFilter) return;

    File imageFile = File(
        '${filterDir.path}/${filter.filterImage.filename}.${filter.filterImage.mimeType?.extension}');
    if (!await imageFile.exists()) return;
    filter.filterImage.rawData =
        await ImageService.loadImageFromFile(imageFile);
  }

  /// Baut rekursiv den Filter als JSON aus dem angegebenen Ordner auf.
  Future<Map<String, dynamic>?> _loadFilterAsJSONRecursively(
      final Directory filterDir) async {
    final jsonFile = File('${filterDir.path}/filter.json');
    if (!await jsonFile.exists()) {
      return null;
    }
    final Map<String, dynamic> filterAsJSON =
        jsonDecode(await jsonFile.readAsString());

    final childrenDir = Directory('${filterDir.path}/children');
    if (!await childrenDir.exists()) {
      return filterAsJSON;
    }

    final childDirs = childrenDir.listSync().whereType<Directory>();

    List<Map<String, dynamic>> childrenAsJSON = <Map<String, dynamic>>[];
    for (final Directory childDir in childDirs) {
      final Map<String, dynamic>? childAsJSON =
          await _loadFilterAsJSONRecursively(childDir);
      if (childAsJSON == null) {
        continue;
      }
      childrenAsJSON.add(childAsJSON);
    }
    if (childrenAsJSON.isNotEmpty) {
      filterAsJSON['filterList'] = childrenAsJSON;
    }

    return filterAsJSON;
  }

  /// Löscht den angegebenen [filter] aus dem lokalen Speicher.
  Future<bool> deleteFilter(final Filter filter) async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    final Directory dir = filterDir(filter);
    if (!await dir.exists()) {
      return false;
    }

    try {
      dir.delete(recursive: true);
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Exportiert den Filter in den angegebenen [outputPath].
  Future<File> exportFilter(
      final Filter filter, final String outputPath) async {
    return File('');
  }

  /// Importiert den Filter aus dem angegebenen [filterPack].
  Future<IFilter> importFilter(final File filterPack) async {
    return FilterFactory.fromJSON({});
  }
}
