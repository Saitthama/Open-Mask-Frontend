import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_mask/data/services/image_service.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/filter/templates/image_filter.dart';
import 'package:path/path.dart';

/// Datenhalter-Klasse, welche globale Filterdaten speichert.
class FilterStore extends ChangeNotifier {
  /// Privater Konstruktor für das Singleton-Pattern.
  FilterStore._internal();

  /// Singleton-Instanz.
  static final FilterStore instance = FilterStore._internal();

  /// Der aktuell ausgewählte Filter.
  IFilter? _selectedFilter;

  /// Der Filter, der aktuell im Filter-Editor bearbeitet wird.
  IFilter? _currentlyEditedFilter;

  /// Der Filter, welcher aktuell im Editor ausgewählt ist.
  /// Kann sowohl [currentlyEditedFilter] als auch ein Teil eines [CompositeFilter] sein.
  IFilter? _selectedEditedFilter;

  /// Alle lokalen Filter.
  final List<IFilter> _localFilters = [];

  /// Alle geladenen Community-Filter.
  final List<IFilter> _communityFilters = [];

  /// Der aktuell ausgewählte Filter.
  IFilter? get selectedFilter => _selectedFilter;

  /// Der Filter, der aktuell im Filter-Editor bearbeitet wird.
  IFilter? get currentlyEditedFilter => _currentlyEditedFilter;

  /// Der Filter, welcher aktuell im Editor ausgewählt ist.
  /// Kann sowohl [currentlyEditedFilter] als auch ein Teile eines [CompositeFilter] sein.
  IFilter? get selectedEditedFilter => _selectedEditedFilter;

  /// Alle lokalen Filter.
  List<IFilter> get localFilters => List.unmodifiable(_localFilters);

  /// Alle geladenen Community-Filter.
  List<IFilter> get communityFilters => List.unmodifiable(_communityFilters);

  set selectedFilter(final IFilter? newSelectedFilter) {
    if (newSelectedFilter != _selectedFilter) {
      newSelectedFilter?.load(); // neuen Filter asynchron laden
    }
    _selectedFilter = newSelectedFilter;
    notifyListeners();
  }

  set currentlyEditedFilter(final IFilter? newSelectedEditorFilter) {
    if (newSelectedEditorFilter != _currentlyEditedFilter) {
      newSelectedEditorFilter?.load().then((final value) =>
          notifyListeners()); // Filter für die Bearbeitung asynchron laden
    }
    _currentlyEditedFilter = newSelectedEditorFilter;
    if (newSelectedEditorFilter == null) {
      _selectedEditedFilter = null;
    }
    notifyListeners();
  }

  /// Setzt den Namen des [currentlyEditedFilter] und benachrichtigt Listener.
  void setCurrentlyEditedFilterName(final String name) {
    (_currentlyEditedFilter as Filter).meta.name = name;
    notifyListeners();
  }

  set selectedEditedFilter(final IFilter? selectedEditedFilter) {
    _selectedEditedFilter = selectedEditedFilter;
    notifyListeners();
  }

  /// Evaluiert, welcher Filter im Editor ausgewählt sein soll.
  void _evaluateSelectedEditedFilter() {
    if (currentlyEditedFilter != null) {
      if (currentlyEditedFilter is CompositeFilter &&
          (currentlyEditedFilter as CompositeFilter).filterList.isNotEmpty) {
        _selectedEditedFilter =
            (currentlyEditedFilter as CompositeFilter).filterList.last;
      } else {
        _selectedEditedFilter = currentlyEditedFilter;
      }
    }
  }

  /// Evaluiert, welcher Filter im Editor ausgewählt sein soll und ruft [notifyListeners] auf.
  void evaluateSelectedEditedFilter() {
    _evaluateSelectedEditedFilter();
    notifyListeners();
  }

  /// Fügt den angegebenen [filter] zu den lokalen Filtern hinzu.
  void addLocalFilter(final IFilter filter) {
    _localFilters.add(filter);
    notifyListeners();
  }

  /// Entfernt den angegebenen [filter] aus den [localFilters], falls dieser vorhanden ist.
  bool removeLocalFilter(final IFilter filter) {
    final bool success = _localFilters.remove(filter);
    notifyListeners();
    return success;
  }

  /// Liefert alle eigenen [localFilters] zurück.
  List<IFilter> getOwnFilters() {
    return _localFilters
        .where(
            (final IFilter filter) => (filter as Filter).meta.createdBy != null)
        .toList();
  }

  /// Liefert alle vordefinierten Filter aus den [localFilters] zurück.
  List<IFilter> getPredefinedFilters() {
    return _localFilters
        .where(
            (final IFilter filter) => (filter as Filter).meta.createdBy == null)
        .toList();
  }

  set communityFilters(final List<IFilter> filters) {
    _communityFilters
      ..clear()
      ..addAll(filters);
    notifyListeners();
  }

  /// Fügt den angegebenen Filter zu [currentlyEditedFilter] hinzu.
  /// Falls bereits ein Filter existiert, welcher nicht zusammengesetzt ist,
  /// wird der [currentlyEditedFilter] in einen [CompositeFilter] umgewandelt und der [filter] hinzugefügt.
  void addFilterToEdit(final IFilter filter) {
    if (_currentlyEditedFilter == null &&
        (filter is! CompositeFilter || filter.filterList.isEmpty)) {
      currentlyEditedFilter = filter;
    } else if (_currentlyEditedFilter is! CompositeFilter) {
      CompositeFilter composite =
          FilterFactory.create(FilterType.composite, isCreatedByUser: true)
              as CompositeFilter;
      if (_currentlyEditedFilter != null) {
        composite.addFilter(_currentlyEditedFilter!);
      }
      composite.addFilter(filter);
      currentlyEditedFilter = composite;
    } else {
      (_currentlyEditedFilter as CompositeFilter).addFilter(filter);
      filter.load().then((final value) => notifyListeners());
    }
    _evaluateSelectedEditedFilter();
    notifyListeners();
  }

  /// Erstellt einen neuen Filter zur Bearbeitung und fügt ihn zu [currentlyEditedFilter] hinzu.
  void createFilterToEdit(final FilterType type) {
    IFilter filter = FilterFactory.create(type, isCreatedByUser: true);
    addFilterToEdit(filter);
  }

  /// Lädt das Filterbild des aktuell im Editor ausgewählten Filters vom angegebenen [assetPath]. <br>
  /// Liefert true zurück, wenn das Asset erfolgreich gesetzt und geladen wurde.
  Future<bool> loadSelectedEditedFilterImageFromAsset(
      final String assetPath) async {
    if (selectedEditedFilter is! ImageFilter) {
      return false;
    }
    final imageFilter = selectedEditedFilter as ImageFilter;
    final filename = basenameWithoutExtension(assetPath);
    final filterImage = FilterImage(filename: filename, assetPath: assetPath);
    bool success = await filterImage.loadFromAsset();
    if (success) {
      imageFilter.filterImage.dispose();
      imageFilter.filterImage = filterImage;
    }
    notifyListeners();
    return success;
  }

  /// Lädt das Filterbild des aktuell im Editor ausgewählten Filters von der angegebenen [url]. <br>
  /// Liefert true zurück, wenn das Bild erfolgreich heruntergeladen wurde.
  Future<bool> loadSelectedEditedFilterImageFromUrl(final String url) async {
    if (selectedEditedFilter is! ImageFilter) {
      return false;
    }
    final imageFilter = selectedEditedFilter as ImageFilter;
    final filename = url.split('/').last;
    final filterImage = FilterImage(
      filename: filename.split('.').first,
      imageUrl: url,
    );
    bool success = await filterImage.loadFromURL();
    if (success) {
      imageFilter.filterImage.dispose();
      imageFilter.filterImage = filterImage;
    }
    notifyListeners();
    return success;
  }

  /// Wählt ein neues Filterbild für den aktuell im Editor ausgewählten Filter mit dem [ImagePicker] <br>
  /// Liefert false zurück, wenn der aktuelle Filter kein Bildfilter ist oder das Bild nicht erfolgreich ausgewählt wurde.
  Future<bool> pickSelectedEditedFilterImage() async {
    if (selectedEditedFilter is! ImageFilter) {
      return false;
    }
    final imagePicker = ImagePicker();
    XFile? xFileImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFileImage == null) {
      return false;
    }

    ImageFilter imageFilter =
        (FilterStore.instance.selectedEditedFilter as ImageFilter);
    File imageFile = File(xFileImage.path);
    Uint8List rawData = await ImageService.loadImageFromFile(imageFile);
    ui.Image image = await ImageService.uint8ListToUiImage(rawData);
    imageFilter.filterImage.dispose();
    FilterImage filterImage = FilterImage(
        image: image,
        rawData: rawData,
        filename: basenameWithoutExtension(imageFile.path),
        width: image.width,
        height: image.height);
    imageFilter.filterImage = filterImage;
    notifyListeners();
    return true;
  }

  /// Setzt den lokalen Filter-Speicher vollständig zurück und löscht alle enthaltenen Filter.
  /// Löscht auch alle geladenen Filterbilder.
  void clear() {
    if (_selectedFilter is ImageFilter) {
      (_selectedEditedFilter as ImageFilter).dispose();
    }
    _selectedFilter = null;
    if (_currentlyEditedFilter is ImageFilter) {
      (_currentlyEditedFilter as ImageFilter).dispose();
    }
    _currentlyEditedFilter = null;
    for (final IFilter filter in [..._localFilters, ..._communityFilters]) {
      if (filter is ImageFilter) {
        filter.dispose();
      }
    }
    _localFilters.clear();
    _communityFilters.clear();
    notifyListeners();
  }
}
