import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:open_mask/data/model/image_mime_type.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/data/services/snackbar_service.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_image.dart';
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
  ///         <b>0/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///           <li>image.png</li>
  ///         </ul>
  ///       </li>
  ///       <li>
  ///         <b>1/</b>
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
  ///         <b>0/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///           <li>image.png</li>
  ///         </ul>
  ///       </li>
  ///       <li>
  ///         <b>1/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///         </ul>
  ///       </li>
  ///       <li>
  ///         <b>2/</b>
  ///         <ul>
  ///           <li>filter.json</li>
  ///           <li>
  ///             <b>children/</b>
  ///             <ul>
  ///               <li>
  ///                 <b>0/</b>
  ///                 <ul>
  ///                   <li>filter.json</li>
  ///                 </ul>
  ///               </li>
  ///               <li>
  ///                 <b>1/</b>
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
  Directory filterChildDir(final Directory parent, final int index) =>
      Directory('${parent.path}/children/$index');

  /// Geht sicher, dass der Ordner existiert.
  Future<Directory> ensureDirExists(final Directory dir) async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Liefert zurück, ob der angegebene [filter] bereits lokal gespeichert wurde.
  Future<bool> filterExists(final Filter filter) async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    return await filterDir(filter).exists();
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
            await ensureDirExists(filterChildDir(filterDir, i));
        await _saveFilterRecursively(childDir, child, childAsJSON);
      }
      filterAsJSON.remove('filterList');
    }

    FilterImage? icon = filter.meta.icon;
    if (icon != null) {
      await writeFilterImage(filterDir, icon);
    }

    if (filter is ImageFilter) {
      await writeFilterImage(filterDir, filter.filterImage);
    }

    File file = File('${filterDir.path}/filter.json');
    await file.writeAsString(jsonEncode(filterAsJSON));
  }

  /// Schreibt das übergebene [image] in das [directory].
  Future<void> writeFilterImage(
      final Directory directory, final FilterImage image) async {
    if (image.rawData == null) {
      final success = await image.loadRawData();
      if (!success) return;
    }
    File imageFile = File(
        '${directory.path}/${image.filename}.${image.mimeType?.extension}');
    int i = 0;
    for (i = 1; await imageFile.exists(); i++) {
      imageFile = File(
          '${directory.path}/${image.filename} ($i).${image.mimeType?.extension}');
    }
    if (i != 0) {
      image.filename = basenameWithoutExtension(imageFile.path);
    }
    await imageFile.writeAsBytes(image.rawData!, flush: true);
    if (image.image == null) {
      image.dispose(); // wird gerade nicht verwendet
    }
  }

  /// Lädt alle Filter im Ordner des Nutzers.
  Future<List<IFilter>> loadAllFilters() async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    Directory dir = await ensureDirExists(userFiltersDir);
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
        final dirName = basename(childDir.path);
        final index = int.tryParse(dirName);
        final child = (index != null && index < children.length && index >= 0
                ? children[index]
                : null) ??
            children
                .where((final element) => (element as Filter).uuid == dirName)
                .firstOrNull;
        if (child == null) continue;
        await _loadFilterResourcesRecursively(childDir, child);
      }
    }

    FilterImage? icon = (filter as Filter).meta.icon;
    if (icon != null) {
      File iconFile = File(
          '${filterDir.path}/${icon.filename}.${icon.mimeType?.extension}');
      if (await iconFile.exists()) {
        icon.rawData = await ImageService.loadImageFromFile(iconFile);
      }
    }

    if (filter is ImageFilter) {
      File imageFile = File(
          '${filterDir.path}/${filter.filterImage.filename}.${filter.filterImage.mimeType?.extension}');
      if (!await imageFile.exists()) return;
      filter.filterImage.rawData =
          await ImageService.loadImageFromFile(imageFile);
    }
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

    final childDirs = childrenDir.listSync().whereType<Directory>().toList();

    List<Map<String, dynamic>> childrenAsJSON = <Map<String, dynamic>>[];
    childDirs.sort((final dir1, final dir2) {
      int? dir1Index = int.tryParse(basename(dir1.path));
      int? dir2Index = int.tryParse(basename(dir2.path));
      if (dir1Index == null || dir2Index == null) {
        return 0;
      }
      return dir1Index.compareTo(dir2Index);
    });
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

  /// Exportiert den Filter in einen vom Nutzer gewählten Ordner. <p>
  /// Der Filterordner wird dafür zu einer Zip-Datei komprimiert. <br>
  /// Liefert den Pfad zur exportierten Datei oder null zurück,
  /// je nachdem, ob der Export erfolgreich war. </p>
  Future<String?> exportFilter(final Filter filter) async {
    if (!await FlutterFileDialog.isPickDirectorySupported()) {
      SnackBarService.showMessage('Ordner auswählen wird nicht unterstützt!');
      return null;
    }

    final pickedDirectory = await FlutterFileDialog.pickDirectory();

    if (pickedDirectory == null) {
      return null;
    }

    return exportFilterToDirectory(filter, pickedDirectory);
  }

  /// Exportiert den [filter] in [pickedDirectory] als Zip-Datei.
  Future<String?> exportFilterToDirectory(
      final Filter filter, final DirectoryLocation pickedDirectory) async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    final fileName = '${filter.meta.name}.zip';
    final tmpFile = File('${userFiltersDir.path}/$fileName');
    await tmpFile.create();

    final dataDir = filterDir(filter);
    if (!await dataDir.exists()) {
      await saveFilter(filter);
    }
    try {
      await ZipFile.createFromDirectory(
          sourceDir: dataDir, zipFile: tmpFile, recurseSubDirs: true);
    } catch (e) {
      SnackBarService.showMessage('Fehler beim Export des Filters!');
      return null;
    }

    final filePath = await FlutterFileDialog.saveFileToDirectory(
      directory: pickedDirectory,
      data: tmpFile.readAsBytesSync(),
      mimeType: 'application/zip',
      fileName: fileName,
      replace: true,
    );

    tmpFile.delete(recursive: true);
    return filePath;
  }

  /// Exportiert eine Liste von Filtern.
  Future<List<String>> exportFilterList(final List<Filter> filterList) async {
    List<String> paths = [];

    if (!await FlutterFileDialog.isPickDirectorySupported()) {
      SnackBarService.showMessage('Ordner auswählen wird nicht unterstützt!');
    }

    final pickedDirectory = await FlutterFileDialog.pickDirectory();
    if (pickedDirectory == null) {
      return paths;
    }
    for (final filter in filterList) {
      final String? path =
          await exportFilterToDirectory(filter, pickedDirectory);
      if (path != null) {
        paths.add(path);
      }
    }
    return paths;
  }

  /// Öffnet eine Dateiauswahl und importiert den Filter.
  Future<IFilter?> importFilter() async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    FilePickerResult? result = await FilePicker.pickFiles(
        dialogTitle: 'Filterdatei zum Importieren auswählen',
        type: FileType.custom,
        allowedExtensions: ['zip']);

    File filterPack;
    if (result != null) {
      filterPack = File(result.files.single.path!);
    } else {
      return null;
    }

    return await importFilterFromFile(filterPack);
  }

  /// Importiert den Filter aus dem angegebenen [filterPack].
  Future<IFilter?> importFilterFromFile(final File filterPack) async {
    final destinationDir = await ensureDirExists(
        Directory('${userFiltersDir.path}/${basename(filterPack.path)}.tmp'));
    try {
      await ZipFile.extractToDirectory(
          zipFile: filterPack, destinationDir: destinationDir);
    } catch (e) {
      SnackBarService.showMessage('Fehler beim Import der Datei!');
      return null;
    }

    IFilter? filter = await loadFilter(destinationDir);

    destinationDir.delete(recursive: true);
    return filter;
  }

  /// Öffnet eine Dateiauswahl und importiert alle ausgewählten Filter.
  Future<List<IFilter>> importFilterList() async {
    _docsDir ??= await getApplicationDocumentsDirectory();
    FilePickerResult? result = await FilePicker.pickFiles(
        dialogTitle: 'Filterdatei zum Importieren auswählen',
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: true);

    List<File> filterPacks = [];
    if (result != null) {
      for (final file in result.files) {
        if (file.path == null) continue;
        filterPacks.add(File(file.path!));
      }
    } else {
      return [];
    }

    List<IFilter> filters = [];
    for (final filterPack in filterPacks) {
      IFilter? filter = await importFilterFromFile(filterPack);
      if (filter == null) continue;
      filters.add(filter);
    }

    return filters;
  }
}
